//
//  Model.swift
//  Cellua
//
//  Created by Markus Moenig on 11/6/21.
//

import Foundation

class Model: NSObject, ObservableObject {

    var ctkView     : CTKView!
    var renderer    = Renderer()
    
    @Published var showPreview = true
    
    var mnca        : MNCA
    
    override init() {
        
        mnca = MNCA()

        super.init()        
    }
    
    /// MetalView will pass its embedded CTKView here
    func setView(_ view: CTKView)
    {
        ctkView = view
        ctkView.platformInit(renderer)
        renderer.setView(self, ctkView)
    }
}
