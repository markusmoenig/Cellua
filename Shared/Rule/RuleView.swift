//
//  RuleView.swift
//  Cellua
//
//  Created by Markus Moenig on 14/6/21.
//

import SwiftUI

struct RuleView: View {
    
    var rule             : Rule
    
    @EnvironmentObject private var model    : Model
    
    @State private var modeImage            : String
    @State private var policyImage          : String

    @State private var currentIndex         : Int? = nil

    
    init(rule: Rule) {
        self.rule = rule
        
        _modeImage = State(initialValue: rule.mode == .Absolute ? "textformat.123" : "percent")
        _policyImage = State(initialValue: rule.policy == .Ignore ? "square" : (rule.policy == .Zero ? "0.square" : "1.square"))
    }
    
    var body: some View {
        
        let columns = [
            GridItem(.adaptive(minimum: 30), spacing: 1)
        ]
        
        ZStack {
            
            MetalView()
                .opacity(model.showPreview ? 1 : 0.2)
        
            if model.showPreview == false {
                VStack {

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
                }
            }
        }
            
        #if os(macOS)
        .frame(minWidth: 400, idealWidth: 700, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
        #endif
        
        .navigationTitle(rule.name)
        .animation(.linear)//, value: 1)
        
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {

                Menu {
                    Button(action: {
                        rule.mode = .Absolute
                        modeImage = "textformat.123"
                        model.renderer.update()
                    }) {
                        Text("Absolute")
                        Image(systemName: "textformat.123")
                    }
                    
                    Button(action: {
                        rule.mode = .Average
                        modeImage = "percent"
                        model.renderer.update()
                    }) {
                        Text("Average")
                        Image(systemName: "percent")
                    }
                } label: {
                    Image(systemName: modeImage)
                }
                
                Menu {
                    Button(action: {
                        rule.policy = .Ignore
                        policyImage = "square"
                        model.renderer.update()
                    }) {
                        Text("Ignore Current Value")
                        Image(systemName: "square")
                    }
                    
                    Button(action: {
                        rule.policy = .Zero
                        policyImage = "0.square"
                        model.renderer.update()
                    }) {
                        Text("Current Value is 0")
                        Image(systemName: "0.square")
                    }
                    
                    Button(action: {
                        rule.policy = .One
                        policyImage = "1.square"
                        model.renderer.update()
                    }) {
                        Text("Current Value is 1")
                        Image(systemName: "1.square")
                    }
                } label: {
                    Image(systemName: policyImage)
                }
                
                Button(action: {
                    model.showPreview.toggle()
                }) {
                    Image(systemName: model.showPreview ? "eye" : "eye.slash")
                }
            }
        }
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
