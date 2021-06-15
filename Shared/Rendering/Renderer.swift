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
        
    var defaultLibrary  : MTLLibrary? = nil

    /// The precompiled compute states
    var computeStates   : [Int: MTLComputePipelineState] = [:]
    
    var commandQueue    : MTLCommandQueue? = nil
    var commandBuffer   : MTLCommandBuffer? = nil
    
    var pingPong        : Bool = false
    
    // The buffers for the shapes, rules and the usage indicator
    
    var shapeABuffer    : MTLBuffer? = nil
    var shapeBBuffer    : MTLBuffer? = nil
    var shapeCBuffer    : MTLBuffer? = nil

    var rule1Buffer     : MTLBuffer? = nil
    var rule2Buffer     : MTLBuffer? = nil
    var rule3Buffer     : MTLBuffer? = nil
    var rule4Buffer     : MTLBuffer? = nil
    
    // Usage indicator for each of the above 7 buffers
    
    var arraysUsed      : [Int32]
    var buffersUsed     : MTLBuffer? = nil
    
    // RulesMetaData
    
    var arraysMetaData  : [Int32]
    var buffersMetaData : MTLBuffer? = nil

    init() {
        arraysUsed = Array<Int32>(repeating: 0, count: 7)
        // 5 Ints per rule * 4
        arraysMetaData = Array<Int32>(repeating: 0, count: 20)
    }
    
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
            computeStates[ComputeStates.EvalShapes.rawValue] = createComputeState(name: "evalShapes")
        }
    }
    
    /// Resets rendering by seting the valueTexture to random values
    func reset()
    {
        guard let texture = valueTexture, let model = model else {
            return
        }
        
        // Check which of the shape or rule arrays are actually used
        // We assume shapeA and rule1 are always used
        
        arraysUsed[0] = 1; arraysUsed[3] = 1;

        func checkArray(array: inout Array<Int32>, count: Int) -> Int32 {
            var used: Int32 = 0
            
            for i in 0..<count {
                if array[i] == 1 {
                    used = 1
                    break
                }
            }
            return used
        }
        
        let shapeArrayCount = 17*17
        let ruleArrayCount = 200

        arraysUsed[1] = checkArray(array: &model.mnca.shapes[1].pixels17x17, count: shapeArrayCount)
        arraysUsed[2] = checkArray(array: &model.mnca.shapes[2].pixels17x17, count: shapeArrayCount)

        arraysUsed[4] = checkArray(array: &model.mnca.rules[1].ruleValues, count: ruleArrayCount)
        arraysUsed[5] = checkArray(array: &model.mnca.rules[2].ruleValues, count: ruleArrayCount)
        arraysUsed[6] = checkArray(array: &model.mnca.rules[3].ruleValues, count: ruleArrayCount)
        
        // Copy the rules to the meta data buffers, 5 Int32 per rule
        
        // Offset 0: Shape Nr
        // Offset 1: Mode (Absolute / Average)
        // Offset 2: Policy
        
        var offset = 0
        for i in 0..<4 {
            let rule = model.mnca.rules[i]
                        
            arraysMetaData[offset] = Int32(rule.shape.rawValue)
            arraysMetaData[offset + 1] = Int32(rule.mode.rawValue)
            arraysMetaData[offset + 2] = Int32(rule.policy.rawValue)
            
            offset += 5
        }
        
        // Create or update update the MTLBuffers

        if shapeABuffer == nil {
            // Create all buffers
            
            func createBuffer(array: inout Array<Int32>, count: Int) -> MTLBuffer? {
                array.withUnsafeMutableBytes { ptr in
                    return view?.device!.makeBuffer(bytes: ptr.baseAddress!, length: count * MemoryLayout<Int32>.stride, options: [])!
                }
            }
            
            shapeABuffer = createBuffer(array: &model.mnca.shapes[0].pixels17x17, count: shapeArrayCount)
            shapeBBuffer = createBuffer(array: &model.mnca.shapes[1].pixels17x17, count: shapeArrayCount)
            shapeCBuffer = createBuffer(array: &model.mnca.shapes[2].pixels17x17, count: shapeArrayCount)
                        
            rule1Buffer = createBuffer(array: &model.mnca.rules[0].ruleValues, count: ruleArrayCount)
            rule2Buffer = createBuffer(array: &model.mnca.rules[1].ruleValues, count: ruleArrayCount)
            rule3Buffer = createBuffer(array: &model.mnca.rules[2].ruleValues, count: ruleArrayCount)
            rule4Buffer = createBuffer(array: &model.mnca.rules[3].ruleValues, count: ruleArrayCount)
            
            buffersUsed = createBuffer(array: &arraysUsed, count: 7)
            buffersMetaData = createBuffer(array: &arraysMetaData, count: 20)
        } else {
            // Update only the buffers which are used
            
            shapeABuffer!.contents().copyMemory(from: model.mnca.shapes[0].pixels17x17, byteCount: shapeArrayCount * MemoryLayout<Int32>.stride)
            if arraysUsed[1] == 1 {
                shapeBBuffer!.contents().copyMemory(from: model.mnca.shapes[1].pixels17x17, byteCount: shapeArrayCount * MemoryLayout<Int32>.stride)
            }
            if arraysUsed[2] == 2 {
                shapeCBuffer!.contents().copyMemory(from: model.mnca.shapes[2].pixels17x17, byteCount: shapeArrayCount * MemoryLayout<Int32>.stride)
            }

            rule1Buffer!.contents().copyMemory(from: model.mnca.rules[0].ruleValues, byteCount: ruleArrayCount * MemoryLayout<Int32>.stride)
            if arraysUsed[4] == 1 {
                rule2Buffer!.contents().copyMemory(from: model.mnca.rules[1].ruleValues, byteCount: ruleArrayCount * MemoryLayout<Int32>.stride)
            }
            if arraysUsed[5] == 1 {
                rule2Buffer!.contents().copyMemory(from: model.mnca.rules[2].ruleValues, byteCount: ruleArrayCount * MemoryLayout<Int32>.stride)
            }
            if arraysUsed[6] == 1 {
                rule2Buffer!.contents().copyMemory(from: model.mnca.rules[3].ruleValues, byteCount: ruleArrayCount * MemoryLayout<Int32>.stride)
            }
            
            buffersUsed!.contents().copyMemory(from: arraysUsed, byteCount: arraysUsed.count * MemoryLayout<Int32>.stride)
            
            buffersMetaData!.contents().copyMemory(from: arraysMetaData, byteCount: arraysMetaData.count * MemoryLayout<Int32>.stride)
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
        checkTextures()

        if needsReset {
            reset()
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
                computeEncoder.setBuffer(shapeBBuffer, offset: 0, index: 3)
                computeEncoder.setBuffer(shapeCBuffer, offset: 0, index: 4)
                
                computeEncoder.setBuffer(rule1Buffer, offset: 0, index: 5)
                computeEncoder.setBuffer(rule2Buffer, offset: 0, index: 6)
                computeEncoder.setBuffer(rule3Buffer, offset: 0, index: 7)
                computeEncoder.setBuffer(rule4Buffer, offset: 0, index: 8)

                computeEncoder.setBuffer(buffersUsed, offset: 0, index: 9)
                computeEncoder.setBuffer(buffersMetaData, offset: 0, index: 10)

                computeEncoder.setTexture(resultTexture, index: 11)

                calculateThreadGroups(evalShapes, computeEncoder, texture.width, texture.height)
            }
            computeEncoder.endEncoding()
        }
        
        stopCompute(waitUntilCompleted: true)
        
        pingPong.toggle()
    }
    
    /// Called from the outside to restart the renderer
    func update() {
        needsReset = true
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
    
    #if false
    // Unused right now, initially I wanted to dynamically compile the shader.
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
    #endif
}
