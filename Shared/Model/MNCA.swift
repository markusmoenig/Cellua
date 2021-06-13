//
//  MNCA.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import Foundation

class MNCA : Codable, Equatable {
    
    var shapes          : [Shape] = []
    var id              = UUID()
    var name            = ""
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case shapes
    }
    
    init(_ name: String = "Unnamed")
    {
        self.name = name
        
        shapes.append(Shape("Shape A"))
        shapes.append(Shape("Shape B"))
        shapes.append(Shape("Shape C"))
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shapes = try container.decode([Shape].self, forKey: .shapes)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(shapes, forKey: .shapes)
    }
    
    static func ==(lhs: MNCA, rhs: MNCA) -> Bool {
        return lhs.id == rhs.id
    }
}
