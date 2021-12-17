//
//  Model.swift
//  Cellua
//
//  Created by Markus Moenig on 11/6/21.
//

import Foundation

class Model: NSObject, ObservableObject {
    
    var mnca        : MNCA
    
    override init() {
        
        mnca = MNCA()

        super.init()        
    }
}
