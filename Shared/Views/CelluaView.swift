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
    
    var renderer            = Renderer()
    var drawables           : MetalDrawables? = nil
    
    var color               : Float = 1

    func reset()
    {
        keysDown = []
        mouseIsDown = false
        hasTap  = false
        hasDoubleTap  = false
        buttonDown = nil
        swipeDirection = nil
    }
    
    func update()
    {
        renderer.render()

        if drawables?.encodeStart(float4(0,0,0,0)) != nil {
            
            if let texture = renderer.resultTexture {
                drawables?.drawBox(position: float2(0,0), size: float2(Float(texture.width), Float(texture.height)), rounding: 0, borderSize: 0, onion: 0, fillColor: float4(0,0,0,1), borderColor: float4(0,0,0,0), texture: texture)
            }
            
            drawables?.encodeEnd()
        }
    }
    
    /// Setup the view
    func platformInit(_ model: Model)
    {
        drawables = MetalDrawables(self)
        
        #if os(OSX)
        layer?.isOpaque = false
        #endif
        
        renderer.setView(model, self)
    }
    
    #if os(OSX)

    override public var acceptsFirstResponder: Bool { return true }

    func setMousePos(_ event: NSEvent)
    {
        var location = event.locationInWindow
        location.y = location.y - CGFloat(frame.height)
        location = convert(location, from: nil)
        
        mousePos.x = Float(location.x)
        mousePos.y = -Float(location.y)
    }
    
    override public func keyDown(with event: NSEvent)
    {
        keysDown.append(Float(event.keyCode))
    }
    
    override public func keyUp(with event: NSEvent)
    {
        keysDown.removeAll{$0 == Float(event.keyCode)}
    }
        
    override public func mouseDown(with event: NSEvent) {
        setMousePos(event)
        //core.nodesWidget.touchDown(mousePos)
    }
    
    override public func mouseDragged(with event: NSEvent) {
        setMousePos(event)
        //core.nodesWidget.touchMoved(mousePos)
    }
    
    override public func mouseUp(with event: NSEvent) {
        mouseIsDown = false
        hasTap = false
        hasDoubleTap = false
        setMousePos(event)
        //core.nodesWidget.touchUp(mousePos)
    }
    
    override public func scrollWheel(with event: NSEvent) {
        //core.nodesWidget.scrollWheel(float3(Float(event.deltaX), Float(event.deltaY), Float(event.deltaZ)))
    }

    #endif
}

#if os(OSX)
struct CelluaView: NSViewRepresentable {
    
    var trackingArea        : NSTrackingArea?

    @EnvironmentObject private var model: Model

    init()
    {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<CelluaView>) -> MTKView {
        let ctkView = CTKView(frame: NSMakeRect(0, 0, 100, 100))
        
        ctkView.delegate = context.coordinator
        ctkView.preferredFramesPerSecond = 60
        ctkView.enableSetNeedsDisplay = false
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            ctkView.device = metalDevice
        }
        ctkView.framebufferOnly = false
        ctkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        ctkView.drawableSize = ctkView.frame.size
        ctkView.isPaused = false
        
        ctkView.platformInit(model)
        
        return ctkView
    }
    
    func updateNSView(_ view: MTKView, context: NSViewRepresentableContext<CelluaView>) {
        if let ctkView = view as? CTKView {
            ctkView.update()
        }
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent              : CelluaView
        var metalDevice         : MTLDevice!
        var metalCommandQueue   : MTLCommandQueue!
        
        init(_ parent: CelluaView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.metalDevice = metalDevice
            }
            self.metalCommandQueue = metalDevice.makeCommandQueue()!
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            if let ctkView = view as? CTKView {
                ctkView.update()
            }
        }
        
        func draw(in view: MTKView) {
            if let ctkView = view as? CTKView {
                ctkView.update()
            }
        }
    }
}
#else
struct CelluaView: UIViewRepresentable {
    typealias UIViewType = MTKView

    @EnvironmentObject private var model: Model

    init()
    {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MetalView>) -> MTKView {
        let mtkView = CTKView()
        
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
        mtkView.isPaused = false
        
        model.setView(mtkView)
        
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
            if let ctkView = view as? CTKView {
                ctkView.update()
            }
        }
    }
}
#endif
