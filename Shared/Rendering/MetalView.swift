//
//  MetalView.swift
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

import SwiftUI
import MetalKit

public class CTKView        : MTKView
{
    //var core                : Core!

    var keysDown            : [Float] = []
    
    var mouseIsDown         : Bool = false
    var mousePos            = float2(0, 0)
    
    var hasTap              : Bool = false
    var hasDoubleTap        : Bool = false
    
    var buttonDown          : String? = nil
    var swipeDirection      : String? = nil

    var commandIsDown       : Bool = false
    var shiftIsDown         : Bool = false
    
    var renderer            : Renderer? = nil
    var drawables           : MetalDrawables? = nil

    func reset()
    {
        keysDown = []
        mouseIsDown = false
        hasTap  = false
        hasDoubleTap  = false
        buttonDown = nil
        swipeDirection = nil
    }
    
    public override func draw()
    {
        renderer?.render()
        
        if drawables?.encodeStart(float4(0,0,0,0)) != nil {
            
            if let texture = renderer?.valueTexture {
                drawables?.drawBox(position: float2(0,0), size: float2(Float(texture.width), Float(texture.height)), rounding: 0, borderSize: 0, onion: 0, fillColor: float4(0,0,0,1), borderColor: float4(0,0,0,0), texture: texture)
            }
            
            drawables?.encodeEnd()
        }
    }

    #if os(OSX)
        
    override public var acceptsFirstResponder: Bool { return true }
    
    /// Setup the view
    func platformInit(_ renderer: Renderer)
    {
        self.renderer = renderer
        drawables = MetalDrawables(self)
        layer?.isOpaque = false
    }
    
    #endif
}

#if os(OSX)
struct MetalView: NSViewRepresentable {
    
    var trackingArea        : NSTrackingArea?

    @EnvironmentObject private var model: Model

    init()
    {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let ctkView =  CTKView()
        
        ctkView.delegate = context.coordinator
        ctkView.preferredFramesPerSecond = 60
        ctkView.enableSetNeedsDisplay = true
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            ctkView.device = metalDevice
        }
        ctkView.framebufferOnly = false
        ctkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        ctkView.drawableSize = ctkView.frame.size
        ctkView.enableSetNeedsDisplay = true
        ctkView.isPaused = true
        
        model.setView(ctkView)

        return ctkView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent: MetalView
        var metalDevice: MTLDevice!
        var metalCommandQueue: MTLCommandQueue!
        
        init(_ parent: MetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.metalDevice = metalDevice
            }
            self.metalCommandQueue = metalDevice.makeCommandQueue()!
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
        
        func draw(in view: MTKView) {
        }
    }
}
#else
struct MetalView: UIViewRepresentable {
    typealias UIViewType = MTKView
    var core             : Core!

    var viewType            : DMTKView.MetalViewType

    init(_ core: Core,_ viewType: DMTKView.MetalViewType)
    {
        self.core = core
        self.viewType = viewType
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MetalView>) -> MTKView {
        let mtkView = DMTKView()
        mtkView.core = core
        mtkView.viewType = viewType
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
                
        if viewType == .Preview {
            core.setupView(mtkView)
        } else
        if viewType == .Nodes {
            core.setupNodesView(mtkView)
        }
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MetalView>) {
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent: MetalView
        var metalDevice: MTLDevice!
        var metalCommandQueue: MTLCommandQueue!
        
        init(_ parent: MetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.metalDevice = metalDevice
            }
            self.metalCommandQueue = metalDevice.makeCommandQueue()!
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
        
        func draw(in view: MTKView) {
            if parent.viewType == .Preview {
                parent.core.drawPreview()
            } else
            if parent.viewType == .Nodes {
                parent.core.drawNodes()
            }
        }
    }
}
#endif
