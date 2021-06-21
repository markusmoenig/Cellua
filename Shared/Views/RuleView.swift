//
//  RuleView.swift
//  Cellua
//
//  Created by Markus Moenig on 14/6/21.
//

import SwiftUI

struct RuleView: View {
        
    @EnvironmentObject private var model    : Model
    
    @State private var modeImage            : String = ""

    @State private var currentIndex         : Int? = nil

    @State var rule                         : Rule? = nil
    
    let ruleDigits                          = ["", "0", "1"]

    init() {
    }
    
    var body: some View {
        
        let columns = [
            GridItem(.adaptive(minimum: 30), spacing: 1)
        ]
        
        ZStack {
            
            MetalView()
                .opacity(1)
                .allowsHitTesting(false)
        
            if model.showPreview == false {
                VStack {

                    Spacer()
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white).opacity(0.2)
                            .frame(maxWidth: 11 * 30 + 9, maxHeight: 11 * 30 + 9)

                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(0..<100) { index in
                                ZStack {
                                    Rectangle()
                                        .fill(getColorForIndex(index))
                                        .frame(width: 30, height: 30)
                                        .onTapGesture(perform: {
                                            if let rule = rule {
                                                if rule.ruleValues[index] == -1 {
                                                    rule.ruleValues[index] = 0
                                                    model.renderer.needsReset = true
                                                    currentIndex = index
                                                } else
                                                if rule.ruleValues[index] == 0 {
                                                    rule.ruleValues[index] = 1
                                                    if rule.ruleValues[index + 100] == 4 {
                                                        rule.ruleValues[index + 100] = 0
                                                    }
                                                    model.renderer.needsReset = true
                                                    currentIndex = index
                                                } else
                                                if rule.ruleValues[index] == 1 {
                                                    rule.ruleValues[index] = -1
                                                    model.renderer.needsReset = true
                                                    currentIndex = index
                                                }
                                            }
                                            currentIndex = nil
                                        })
                                        .padding(0)
                                    
                                    
                                    .contextMenu {
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 0
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("White")
                                                .foregroundColor(.white)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 1
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Black")
                                                .foregroundColor(.black)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 2
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Blue")
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 3
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Brown")
                                                .foregroundColor(.brown)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 4
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Clear")
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 5
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Green")
                                                .foregroundColor(.green)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 6
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Orange")
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 7
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Pink")
                                                .foregroundColor(.pink)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 8
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Red")
                                                .foregroundColor(.red)
                                        }
                                        
                                        Button(action: {
                                            rule?.ruleValues[index + 100] = 9
                                            model.renderer.needsReset = true
                                            currentIndex = index
                                            currentIndex = nil
                                        }) {
                                            Text("Yellow")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    /*
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
                                    colors.append(PaletteColor(.yellow))*/
                                    
                                    if let rule = rule {
                                        Text(ruleDigits[Int(rule.ruleValues[index]) + 1] )
                                            .allowsHitTesting(false)
                                    }
                                    
                                    if index == currentIndex {
                                    }
                                    
                
                                }
                            }
                        }
                        .frame(maxWidth: 10 * 30 + 9)
                    }
                    
                    Spacer()
                }
            }
        }

        .toolbar {
            
            ToolbarItemGroup(placement: .automatic) {
                Button(action: {
                    rule = model.mnca.rules[0]
                }) {
                    Image(systemName: rule === model.mnca.rules[0] ? "1.square.fill" : "1.square")
                }
                
                Button(action: {
                    rule = model.mnca.rules[1]
                }) {
                    Image(systemName: rule === model.mnca.rules[1] ? "2.square.fill" : "2.square")
                }
                
                Button(action: {
                    rule = model.mnca.rules[2]
                }) {
                    Image(systemName: rule === model.mnca.rules[2] ? "3.square.fill" : "3.square")
                }
            }
            
            ToolbarItemGroup(placement: .automatic) {
                
                Menu {
                    Button(action: {
                        if let rule = rule {
                            rule.mode = .Absolute
                            modeImage = "textformat.123"
                            model.renderer.update()
                        }
                    }) {
                        Text("Absolute")
                        Image(systemName: "textformat.123")
                    }
                    
                    Button(action: {
                        if let rule = rule {
                            rule.mode = .Average
                            modeImage = "percent"
                            model.renderer.update()
                        }
                    }) {
                        Text("Average")
                        Image(systemName: "percent")
                    }
                } label: {
                    Image(systemName: modeImage)
                }
                
                Button(action: {
                    model.showPreview.toggle()
                }) {
                    Image(systemName: model.showPreview ? "eye" : "eye.slash")
                }
            }
        }
        
        #if os(macOS)
        .frame(minWidth: 400, idealWidth: 700, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
        #endif

        .onAppear(perform: {
            rule = model.mnca.rules[0]
            
            if let rule = rule {
                modeImage = rule.mode == .Absolute ? "textformat.123" : "percent"
            }
        })

        .navigationTitle(rule != nil ? rule!.name : "")
        .animation(.linear)//, value: 1)
    }
    
    /// Returns the right color for the index
    func getColorForIndex(_ index: Int) -> Color {
        
        if let rule = rule {
            
            let colorIndex = rule.ruleValues[index + 100]
            if colorIndex >= 0 && colorIndex != 4 {
                return model.mnca.colors[Int(colorIndex)].color.opacity(0.7)
            }
        }
        
        return .black.opacity(0.5)
    }
}
