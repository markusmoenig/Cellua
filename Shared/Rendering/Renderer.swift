//
//  Renderer.swift
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

import MetalKit

class Renderer {
    
    enum ComputeStates : Int {
        case ResetTexture, EvalShapes
    }
    
    /// Reference to the model
    var model           : Model? = nil
    
    /// Reference to the current CTKView
    var view            : CTKView? = nil
    
    /// The value textures
    var valueTexture    : MTLTexture? = nil
    var valueTexture2   : MTLTexture? = nil
    var resultTexture   : MTLTexture? = nil

    /// Set to true if the renderer needs to reset (on resize, new shapes / rules etc).
    var needsReset      : Bool = true
    
    var rulesChanged    : Bool = true
    
    var defaultLibrary  : MTLLibrary? = nil

    /// The precompiled compute states
    var computeStates   : [Int: MTLComputePipelineState] = [:]
    
    var commandQueue    : MTLCommandQueue? = nil
    var commandBuffer   : MTLCommandBuffer? = nil
    
    var pingPong        : Bool = false
    
    var shapeABuffer    : MTLBuffer? = nil
    var shapeBBuffer    : MTLBuffer? = nil
    var shapeCBuffer    : MTLBuffer? = nil
    
    var isStarted       = false

    deinit {
        destroyTextures()
        if let shapeABuffer = shapeABuffer {
            shapeABuffer.setPurgeableState(.empty)
        }
    }
    
    /// Sets the current CTKView which represents a context switch, reallocate all textures
    func setView(_ model: Model,_ view : CTKView)
    {
        self.model = model
        self.view = view
        
        // On the first init create the compute states
        if defaultLibrary == nil {
            defaultLibrary = view.device?.makeDefaultLibrary()
            computeStates[ComputeStates.ResetTexture.rawValue] = createComputeState(name: "resetTexture")
            //computeStates[ComputeStates.EvalShapes.rawValue] = createComputeState(name: "evalShapes")
        }
    }
    
    /// Resets rendering by seting the valueTexture to random values
    func reset()
    {
        // If the rules changed start compiling
        if rulesChanged {
            compile()
            rulesChanged = false
        }
        
        guard let texture = valueTexture, let model = model else {
            return
        }
        
        // Update the shape buffers
        
        if shapeABuffer == nil {
            model.mnca.shapes[0].pixels17x17.withUnsafeMutableBytes { ptr in
                shapeABuffer = view?.device!.makeBuffer(bytes: ptr.baseAddress!, length: 17*17 * MemoryLayout<Int32>.stride, options: [])!
            }
        } else {
            shapeABuffer!.contents().copyMemory(from: model.mnca.shapes[0].pixels17x17, byteCount: 17*17 * MemoryLayout<Int32>.stride)

        }
        
        pingPong = false
        
        startCompute()
        
        guard let commandBuffer = commandBuffer else {
            return
        }

        if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
            
            if let state = computeStates[ComputeStates.ResetTexture.rawValue] {
            
                computeEncoder.setComputePipelineState( state )
                computeEncoder.setTexture( valueTexture, index: 0 )
                    
                calculateThreadGroups(state, computeEncoder, texture.width, texture.height)
                computeEncoder.endEncoding()
            }
        }
        
        stopCompute(waitUntilCompleted: true)
        needsReset = false
    }
    
    /// Render a frame
    func render()
    {
        if isStarted == false {
            return
        }
        
        checkTextures()
        
        if needsReset == true {
            compile()
            reset()
            return
        }
        
        guard let texture = valueTexture else {
            return
        }
        
        startCompute()

        if let computeEncoder = commandBuffer?.makeComputeCommandEncoder() {
            
            // Evaluate shapes
            if let evalShapes = computeStates[ComputeStates.EvalShapes.rawValue] {
            
                computeEncoder.setComputePipelineState( evalShapes )
                
                // Ping pong value texture

                if pingPong == false {
                    computeEncoder.setTexture( valueTexture, index: 0 )
                    computeEncoder.setTexture( valueTexture2, index: 1 )
                } else {
                    computeEncoder.setTexture( valueTexture2, index: 0 )
                    computeEncoder.setTexture( valueTexture, index: 1 )
                }
                    
                computeEncoder.setBuffer(shapeABuffer, offset: 0, index: 2)
                computeEncoder.setTexture( resultTexture, index: 3 )

                calculateThreadGroups(evalShapes, computeEncoder, texture.width, texture.height)
            }
            computeEncoder.endEncoding()
        }
        
        stopCompute(waitUntilCompleted: true)
        
        pingPong.toggle()
    }
    
    /// Check if all textures have the correct size
    func checkTextures()
    {
        guard let view = view else { return }
        
        let frameSize = SIMD2<Int>(Int(view.frame.width), Int(view.frame.height))
        
        func checkTexture(_ texture: inout MTLTexture?) {
            if texture == nil || texture!.width != frameSize.x || texture!.height != frameSize.y {
                needsReset = true
                
                //texture?.setPurgeableState(.empty)
                texture = allocTexture(size: frameSize, format: .rgba32Float)
            }
        }
        
        checkTexture(&valueTexture)
        checkTexture(&valueTexture2)
        checkTexture(&resultTexture)
    }
    
    /// Allocate a texture of the given size and format
    func allocTexture(size: SIMD2<Int>, format: MTLPixelFormat) -> MTLTexture?
    {
        guard let view = view else { return nil }

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = MTLTextureType.type2D
        textureDescriptor.pixelFormat = format
        textureDescriptor.width = size.x != 0 ? size.x : 1
        textureDescriptor.height = size.y != 0 ? size.y : 1
        
        textureDescriptor.usage = MTLTextureUsage.unknown
        return view.device?.makeTexture(descriptor: textureDescriptor)
    }
    
    /// Deallocate all textures
    func destroyTextures()
    {
        valueTexture?.setPurgeableState(.empty)
        valueTexture = nil
        
        valueTexture2?.setPurgeableState(.empty)
        valueTexture2 = nil
        
        resultTexture?.setPurgeableState(.empty)
        resultTexture = nil
    }
    
    /// Starts compute operation
    func startCompute()
    {
        if commandQueue == nil {
            commandQueue = view?.device?.makeCommandQueue()
        }
        
        if commandQueue != nil {
            commandBuffer = commandQueue?.makeCommandBuffer()
        }
    }
    
    /// Stops compute operation
    func stopCompute(syncTexture: MTLTexture? = nil, waitUntilCompleted: Bool = false)
    {
        #if os(OSX)
        if let texture = syncTexture {
            let blitEncoder = commandBuffer!.makeBlitCommandEncoder()!
            blitEncoder.synchronize(texture: texture, slice: 0, level: 0)
            blitEncoder.endEncoding()
        }
        #endif
        commandBuffer?.commit()
        if waitUntilCompleted {
            commandBuffer?.waitUntilCompleted()
        }
        commandBuffer = nil
    }
    
    /// Compute the threads and thread groups for the given state and texture
    func calculateThreadGroups(_ state: MTLComputePipelineState, _ encoder: MTLComputeCommandEncoder,_ width: Int,_ height: Int, limitThreads: Bool = false)
    {
        let w = limitThreads ? 1 : state.threadExecutionWidth
        let h = limitThreads ? 1 : state.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSize(width: (width + w - 1) / w, height: (height + h - 1) / h, depth: 1)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    /// Creates a compute state from an optional library and the function name
    func createComputeState(library: MTLLibrary? = nil, name: String) -> MTLComputePipelineState?
    {
        guard let view = view else { return nil }

        let function : MTLFunction?
            
        if library != nil {
            function = library!.makeFunction( name: name )
        } else {
            function = defaultLibrary!.makeFunction( name: name )
        }
        
        var computePipelineState : MTLComputePipelineState?
        
        if function == nil {
            return nil
        }
        
        do {
            computePipelineState = try view.device?.makeComputePipelineState( function: function! )
        } catch {
            print( "computePipelineState failed" )
            return nil
        }

        return computePipelineState
    }
    
    func compile()
    {
        var code =
        """
                
        #include <metal_stdlib>
        using namespace metal;
        
        uint2 wrap(int2 gid, int2 size) {
            return uint2((gid + size) % size);
        }
        
        /// Resets the value texture by initializing it with some pseudo-random hash values
        kernel void evalShapes(texture2d<half, access::read>  valueTexture      [[texture(0)]],
                               texture2d<half, access::write> valueTextureOut   [[texture(1)]],
                               constant int *shapeA                             [[buffer(2)]],
                               texture2d<half, access::write> resultTexture     [[texture(3)]],
                               uint2 gid                                        [[thread_position_in_grid]])
        {
            int2 size = int2(valueTexture.get_width(), valueTexture.get_height());

            int count = 0;
            
            int loop = 0;
            int2 g = int2(gid.x, gid.y);
            
            for (int y = 0; y < 17; y += 1) {
                for (int x = 0; x < 17; x += 1) {
                    
                    if (shapeA[loop] == 1) {
                        
                        int2 offset = int2(x - 8, y - 8);
                        
                        count += valueTexture.read(wrap(g -  offset, size)).x;
                    }
                    
                    loop += 1;
                }
            }

            int current = valueTexture.read(gid).x;
            
            // Rules
            
            half value = 0;
            half4 result = 0;
            
            if (count == 2 && current == 1) {
                value = 1;
                result = half4(0, 0, 1, 1);
            } else
            if (count == 3)
            {
                value = 1;
                result = half4(1, 1, 1, 1);
            } else {
                value = 0;
                result = 0;
            }
            
            valueTextureOut.write(value, gid);
            resultTexture.write(result, gid);
        }
        """
        
        guard let model = model else {
            return
        }
        
        let compiledCB : MTLNewLibraryCompletionHandler = { (library, error) in
            
            if let error = error {
                print(error)
            }

            self.computeStates[ComputeStates.EvalShapes.rawValue] = self.createComputeState(library: library, name: "evalShapes")
        }
        
        view?.device?.makeLibrary(source: code, options: nil, completionHandler: compiledCB)
    }
}
