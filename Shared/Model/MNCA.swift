//
//  MNCA.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import Foundation
import SwiftUI

class MNCA : Codable, Equatable {
    
    var shapes          : [Shape] = []
    var rules           : [Rule] = []
    var id              = UUID()
    var name            = ""
    
    var colors          : [PaletteColor] = []
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case shapes
        case rules
    }
    
    init(_ name: String = "Unnamed")
    {
        self.name = name
        
        shapes.append(Shape("Shape #1"))
        shapes.append(Shape("Shape #2"))
        shapes.append(Shape("Shape #3"))
        
        rules.append(Rule("Rule #1"))
        rules.append(Rule("Rule #2"))
        rules.append(Rule("Rule #3"))
        
        colors.append(PaletteColor(.white))
        colors.append(PaletteColor(.black))
        colors.append(PaletteColor(.blue))
        colors.append(PaletteColor(.brown))
        colors.append(PaletteColor(.clear))
        colors.append(PaletteColor(.cyan))
        colors.append(PaletteColor(.gray))
        colors.append(PaletteColor(.green))
        colors.append(PaletteColor(.indigo))
        colors.append(PaletteColor(.mint))
        colors.append(PaletteColor(.orange))
        colors.append(PaletteColor(.pink))
        colors.append(PaletteColor(.purple))
        colors.append(PaletteColor(.red))
        colors.append(PaletteColor(.red))
        colors.append(PaletteColor(.teal))
        colors.append(PaletteColor(.yellow))
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shapes = try container.decode([Shape].self, forKey: .shapes)
        rules = try container.decode([Rule].self, forKey: .rules)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(shapes, forKey: .shapes)
        try container.encode(rules, forKey: .rules)
    }
    
    static func ==(lhs: MNCA, rhs: MNCA) -> Bool {
        return lhs.id == rhs.id
    }
}
