//
//  MathLibrary.swift
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

import Foundation

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>

let π = Float.pi

extension Float {
    var radiansToDegrees: Float {
        (self / π) * 180
    }
    var degreesToRadians: Float {
        (self / 180) * π
    }
}

extension Double {
    var radiansToDegrees: Double {
        (self / Double.pi) * 180
    }
    var degreesToRadians: Double {
        (self / 180) * Double.pi
    }
}
