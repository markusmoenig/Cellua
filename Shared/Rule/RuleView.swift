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
    @State private var policyText : String

    @State private var currentIndex : Int? = nil

    
    init(rule: Rule) {
        self.rule = rule
        
        _modeText = State(initialValue: rule.mode == .Absolute ? "Absolute" : "Average")
        _policyText = State(initialValue: rule.policy == .Ignore ? "Ignore" : (rule.policy == .Zero ? "0" : "1"))
    }
    
    var body: some View {
        
        let columns = [
            GridItem(.adaptive(minimum: 30), spacing: 1)
        ]
        
        VStack {            
            HStack {
                VStack {
                    Text("Pixel values")
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
                }.padding()
                VStack {
                    Text("Current value")
                    Menu {
                        Button(action: {
                            rule.policy = .Ignore
                            policyText = "Ignore"
                        }) {
                            Text("Ignore")
                        }
                        
                        Button(action: {
                            rule.policy = .Zero
                            policyText = "0"
                        }) {
                            Text("0")
                        }
                        
                        Button(action: {
                            rule.policy = .One
                            policyText = "1"
                        }) {
                            Text("1")
                        }
                    } label: {
                        Text(policyText)
                    }
                }.padding()
            }
            
            Spacer()

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<100) { index in
                    ZStack {
                        Rectangle()
                            .fill(getColorForIndex(index))
                            .frame(width: 30, height: 30)
                            .onTapGesture(perform: {
                                currentIndex = nil
                                clickedOnIndex(index)
                            })
                            .padding(0)
                        
                        Text(rule.ruleValues[index] == 0 ? "0" : "1")
                            .allowsHitTesting(false)
                        
                        if index == currentIndex {
                        }
                    }
                }
            }
            .frame(maxWidth: 10 * 30 + 9)
            
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
    
    ///
    func clickedOnIndex(_ index: Int) {
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
    }
    
    /// Returns the right color for the index
    func getColorForIndex(_ index: Int) -> Color {
        return .black
    }
}
