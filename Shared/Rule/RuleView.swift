//
//  RuleView.swift
//  Cellua
//
//  Created by Markus Moenig on 14/6/21.
//

import SwiftUI

struct RuleView: View {
    
    var rule             : Rule
    
    @EnvironmentObject private var model: Model
    @State private var modeText : String
    
    @State private var currentIndex : Int? = nil

    
    init(rule: Rule) {
        self.rule = rule
        
        _modeText = State(initialValue: rule.mode == .Absolute ? "Absolute" : "Average")
    }
    
    var body: some View {
        
        let columns = [
            GridItem(.adaptive(minimum: 20), spacing: 1)
        ]
        
        VStack {            
            HStack {
                Menu {
                    Button(action: {
                        rule.mode = .Absolute
                        modeText = "Absolute"
                    }) {
                        Text("Absolute")
                    }
                    
                    Button(action: {
                        rule.mode = .Average
                        modeText = "Average"
                    }) {
                        Text("Average")
                    }
                } label: {
                    Text(modeText)
                }
            }
            
            Spacer()

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<100) { index in
                    ZStack {
                        Rectangle()
                            .fill(getColorForIndex(index))
                            .frame(width: 20, height: 20)
                            .onTapGesture(perform: {
                                
                                if rule.ruleValues[index] == 1 {
                                    rule.ruleValues[index] = 0
                                    model.renderer.needsReset = true
                                    currentIndex = index
                                } else
                                if rule.ruleValues[index] == 0 {
                                    rule.ruleValues[index] = 1
                                    model.renderer.needsReset = true
                                    currentIndex = index
                                }
                                
                                currentIndex = nil

                            })
                            .padding(0)
                        
                        Text(rule.ruleValues[index] == 0 ? "0" : "1")
                        
                        if index == currentIndex {
                        }
                    }
                }
            }
            .frame(maxWidth: 10*20 + 9)
            
            Spacer()
            
            if model.showPreview {
                MetalView()
                    .frame(maxHeight: 100)
            }
        }
        
#if os(macOS)
        .frame(minWidth: 400, idealWidth: 700, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
#endif
        
        .navigationTitle(rule.name)
        .animation(.default)//, value: 1)
    }
    
    /// Returns the right color for the index
    func getColorForIndex(_ index: Int) -> Color {
        
        return .black
    }
}
