//
//  Renderer.swift
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

import MetalKit

class Renderer {
    
    enum ComputeStates : Int {
        case ResetTexture, GameOfLife
    }
    
    /// Reference to the current CTKView
    var view            : CTKView? = nil
    
    /// The value textures
    var valueTexture    : MTLTexture? = nil
    var valueTexture2   : MTLTexture? = nil

    var currentTexture  : MTLTexture? = nil

    /// Set to true if the renderer needs to reset (on resize, new shapes / rules etc).
    var needsReset      : Bool = true
    
    var defaultLibrary  : MTLLibrary? = nil

    /// The precompiled compute states
    var computeStates   : [Int: MTLComputePipelineState] = [:]
    
    var commandQueue    : MTLCommandQueue? = nil
    var commandBuffer   : MTLCommandBuffer? = nil
    
    var pingPong        : Bool = false

    deinit {
        destroyTextures()
    }
    
    /// Sets the current CTKView which represents a context switch, reallocate all textures
    func setView(_ view : CTKView)
    {
        self.view = view
        
        // On the first init create the compute states
        if defaultLibrary == nil {
            defaultLibrary = view.device?.makeDefaultLibrary()
            computeStates[ComputeStates.ResetTexture.rawValue] = createComputeState(name: "resetTexture")
            computeStates[ComputeStates.GameOfLife.rawValue] = createComputeState(name: "gameOfLife")
        }
        destroyTextures()
    }
    
    /// Resets rendering by seting the valueTexture to random values
    func reset()
    {
        guard let texture = valueTexture else {
            return
        }
        
        pingPong = false
        currentTexture = texture
        
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
        
        if needsReset == true {
            reset()
            return
        }
        
        guard let texture = valueTexture else {
            return
        }
        
        startCompute()
        
        guard let commandBuffer = commandBuffer else {
            return
        }

        if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
            
            if let state = computeStates[ComputeStates.GameOfLife.rawValue] {
            
                computeEncoder.setComputePipelineState( state )
                
                if pingPong == false {
                    computeEncoder.setTexture( valueTexture, index: 0 )
                    computeEncoder.setTexture( valueTexture2, index: 1 )
                    currentTexture = valueTexture2
                } else {
                    computeEncoder.setTexture( valueTexture2, index: 0 )
                    computeEncoder.setTexture( valueTexture, index: 1 )
                    currentTexture = valueTexture
                }
                    
                calculateThreadGroups(state, computeEncoder, texture.width, texture.height)
                computeEncoder.endEncoding()
            }
        }
        
        stopCompute(waitUntilCompleted: true)
        
        pingPong.toggle()
    }
    
    /// Check if all textures have the correct size
    func checkTextures()
    {
        guard let view = view else { return }
        
        let frameSize = SIMD2<Int>(Int(view.frame.width), Int(view.frame.height))
        
        if valueTexture == nil || valueTexture!.width != frameSize.x || valueTexture!.height != frameSize.y {
            
            needsReset = true
            
            valueTexture?.setPurgeableState(.empty)
            valueTexture = allocTexture(size: frameSize, format: .rgba32Float)
            
            currentTexture = valueTexture
        }
        
        if valueTexture2 == nil || valueTexture2!.width != frameSize.x || valueTexture2!.height != frameSize.y {
            
            needsReset = true
            
            valueTexture2?.setPurgeableState(.empty)
            valueTexture2 = allocTexture(size: frameSize, format: .rgba32Float)
        }
    }
    
    /// Allocate a texture of the given size and format
    func allocTexture(size: SIMD2<Int>, format: MTLPixelFormat) -> MTLTexture?
    {
        guard let view = view else { return nil }

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = MTLTextureType.type2D
        textureDescriptor.pixelFormat = format
        textureDescriptor.width = size.x
        textureDescriptor.height = size.y
        
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
}
