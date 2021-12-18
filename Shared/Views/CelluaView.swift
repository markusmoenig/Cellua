//
//  CelluaView.swift
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

import SwiftUI
import MetalKit

#if os(OSX)
struct CelluaView: NSViewRepresentable {
    
    var view                    : Binding<CTKView?>
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<CelluaView>) -> MTKView {
        let ctkView = CTKView(frame: NSMakeRect(0, 0, 100, 100))
        
        ctkView.delegate = context.coordinator
        ctkView.preferredFramesPerSecond = 60
        ctkView.enableSetNeedsDisplay = true
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            ctkView.device = metalDevice
        }
        ctkView.framebufferOnly = false
        ctkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        ctkView.drawableSize = ctkView.frame.size
        ctkView.isPaused = true
        
        DispatchQueue.main.async {
            self.view.wrappedValue = ctkView
            ctkView.renderer.updateOnce()
        }

        ctkView.platformInit()
        
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
        mtkView.isPaused = true
        
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
