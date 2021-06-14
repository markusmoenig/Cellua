//
//  MNCA.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import Foundation

class MNCA : Codable, Equatable {
    
    var shapes          : [Shape] = []
    var rules           : [Rule] = []
    var id              = UUID()
    var name            = ""
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case shapes
        case rules
    }
    
    init(_ name: String = "Unnamed")
    {
        self.name = name
        
        shapes.append(Shape("Shape A"))
        shapes.append(Shape("Shape B"))
        shapes.append(Shape("Shape C"))
        
        rules.append(Rule("Rule #1"))
        rules.append(Rule("Rule #2"))
        rules.append(Rule("Rule #3"))
        rules.append(Rule("Rule #4"))
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
