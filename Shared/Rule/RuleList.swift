//
//  RuleList.swift
//  Cellua
//
//  Created by Markus Moenig on 14/6/21.
//

import SwiftUI

struct RuleList: View {
    
    enum RuleItem {
        case rule1
        case rule2
        case rule3
        case rule4
    }
    
    @EnvironmentObject private var model: Model
    
    @State private var selection: RuleItem? = .rule1
    
    var body: some View {

        NavigationView {
            List {
                NavigationLink(tag: RuleItem.rule1, selection: $selection) {
                    RuleView(rule: model.mnca.rules[0])
                } label: {
                    Label("Rule #1", systemImage: "square")
                }
                
                NavigationLink(tag: RuleItem.rule2, selection: $selection) {
                    RuleView(rule: model.mnca.rules[1])
                } label: {
                    Label("Rule #2", systemImage: "square")
                }
                
                NavigationLink(tag: RuleItem.rule3, selection: $selection) {
                    RuleView(rule: model.mnca.rules[2])
                } label: {
                    Label("Rule #3", systemImage: "square")
                }
                
                NavigationLink(tag: RuleItem.rule4, selection: $selection) {
                    RuleView(rule: model.mnca.rules[3])
                } label: {
                    Label("Rule #4", systemImage: "square")
                }
            }
            .navigationTitle("Rules")
        }
    }
}

struct RuleList_Previews: PreviewProvider {
    static var previews: some View {
        RuleList()
    }
}
