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
    
    var pixels17x17     : [Int32]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case pixels17x17
    }
    
    init(_ name: String = "Unnamed")
    {
        self.name = name
        
        pixels17x17 = Array<Int32>(repeating: 0, count: 17*17)
        pixels17x17[(17*17) / 2] = -1
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        pixels17x17 = try container.decode([Int32].self, forKey: .pixels17x17)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(pixels17x17, forKey: .pixels17x17)
    }
    
    static func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.id == rhs.id
    }
}
