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
    
    override init() {
        super.init()
    }
    
    /// MetalView will pass its embedded CTKView here
    func setView(_ view: CTKView)
    {
        ctkView = view
        ctkView.platformInit(renderer)
        renderer.setView(ctkView)
    }
}
