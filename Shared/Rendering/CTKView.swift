//
//  CTKView.swift
//  Cellua
//
//  Created by Markus Moenig on 18/12/21.
//

import MetalKit

public class CTKView        : MTKView
{
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
    
    var xOffset             : Float = 0

    func reset()
    {
        keysDown = []
        mouseIsDown = false
        hasTap  = false
        hasDoubleTap  = false
        buttonDown = nil
        swipeDirection = nil
    }

    /// To prevent updates during startup
    var canUpdate = false
    
    /// Render
    func update()
    {
        if canUpdate == false { return }
        renderer.render()

        if drawables?.encodeStart(float4(0,0,0,0)) != nil {
            
            if let texture = renderer.resultTexture {
                drawables?.drawBox(position: float2(0,0), size: float2(Float(texture.width), Float(texture.height)), rounding: 0, borderSize: 0, onion: 0, fillColor: float4(0,0,0,1), borderColor: float4(0,0,0,0), texture: texture)
            }
            
            drawables?.encodeEnd()
        }
    }
    
    /// Setup the view
    func platformInit()
    {
        drawables = MetalDrawables(self)
        
        #if os(OSX)
        layer?.isOpaque = false
        #endif
        
        renderer.setView(self)
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
