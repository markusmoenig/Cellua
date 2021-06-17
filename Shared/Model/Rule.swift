//
//  Rule.swift
//  Cellua
//
//  Created by Markus Moenig on 14/6/21.
//

import Foundation

class Rule : Codable, Equatable, Hashable {
    
    enum RuleMode : Int, Codable {
        case Absolute, Average
    }
    
    var id              = UUID()
    var name            = ""
    
    var mode            : RuleMode = .Absolute

    /// Contains 100 rule values and their meta data
    var ruleValues      : [Int32]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case mode
        case ruleValues
    }
    
    init(_ name: String = "Unnamed")
    {
        self.name = name
        
        ruleValues = Array<Int32>(repeating: -1, count: 200)
        
        for i in 100..<200 {
            ruleValues[i] = 4
        }
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        mode = try container.decode(RuleMode.self, forKey: .mode)
        ruleValues = try container.decode([Int32].self, forKey: .ruleValues)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(mode, forKey: .mode)
        try container.encode(ruleValues, forKey: .ruleValues)
    }
    
    static func ==(lhs: Rule, rhs: Rule) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
