//
//  PaletteColor.swift
//  Cellua
//
//  Created by Markus Moenig on 16/6/21.
//

import Foundation
import SwiftUI

class PaletteColor : Codable, Equatable, Hashable {
    
    var id              = UUID()
    
    var value           = float4()
    var color           : Color
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case value
    }
    
    init(_ color: Color)
    {
        self.color = color
        value = fromColor(color)
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        value = try container.decode(float4.self, forKey: .value)
        
        self.color = Color(.sRGB, red: Double(value.x), green: Double(value.y), blue: Double(value.z), opacity: Double(value.w))
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
    }
    
    static func ==(lhs: PaletteColor, rhs: PaletteColor) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Convert the value to a SwiftUI Color
    func toColor() -> Color {
        return Color(.sRGB, red: Double(value.x), green: Double(value.y), blue: Double(value.z), opacity: Double(value.w))
    }
    
    /// Sets the color value from an SwiftUI color, returns true if the value is actually different
    @discardableResult func fromColor(_ color: Color) -> float4 {
                
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        #if os(macOS)
        if let color = NSColor(color).usingColorSpace(.deviceRGB) {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #elseif os(iOS)
        let color = UIColor(color)
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        return float4(Float(red), Float(green), Float(blue), Float(alpha))
    }
}
