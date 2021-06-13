//
//  Shape.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import Foundation

class Shape : Codable, Equatable {
    
    var id              = UUID()
    var name            = ""
    
    var pixels9x9       : [Int32]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case pixels9x9
    }
    
    init(_ name: String = "Unnamed")
    {
        self.name = name
        
        pixels9x9 = Array<Int32>(repeating: 0, count: 81)
        pixels9x9[40] = -1
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        pixels9x9 = try container.decode([Int32].self, forKey: .pixels9x9)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(pixels9x9, forKey: .pixels9x9)
    }
    
    static func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.id == rhs.id
    }
}
