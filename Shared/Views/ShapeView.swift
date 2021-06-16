//
//  ShapeView.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import SwiftUI

struct ShapeView: View {
        
    @EnvironmentObject private var model    : Model
    @State var currentIndex                 : Int? = nil
    
    @State var shape                        : Shape? = nil

    init()
    {
    }
    
    var body: some View {
                    
        let columns = [
            GridItem(.adaptive(minimum: 20), spacing: 1)
        ]
        
        ZStack {
            
            MetalView()
                .opacity(model.showPreview ? 1 : 0.5)
            
            if model.showPreview == false {
                VStack {
                    
                    Spacer()

                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(0..<17*17) { index in
                            ZStack {
                                Rectangle()
                                    .fill(getColorForIndex(index))
                                    .frame(width: 20, height: 20)
                                    .onTapGesture(perform: {
                                        
                                        if let shape = shape {
                                            if shape.pixels17x17[index] == 1 {
                                                shape.pixels17x17[index] = 0
                                                model.renderer.needsReset = true
                                                currentIndex = index
                                            } else
                                            if shape.pixels17x17[index] == 0 {
                                                shape.pixels17x17[index] = 1
                                                model.renderer.needsReset = true
                                                currentIndex = index
                                            }
                                        }
                                        
                                        currentIndex = nil

                                    })
                                    .padding(0)
                                
                                
                                if index == currentIndex {
                                }
                            }
                        }
                    }
                    .background(Color.gray)
                    .frame(maxWidth: 17 * 20 + 16)
                    
                    Spacer()
                }
            }
        }
        
        .onAppear(perform: {
            shape = model.mnca.shapes[0]
        })
        
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: {
                    shape = model.mnca.shapes[0]
                }) {
                    Image(systemName: shape === model.mnca.shapes[0] ? "1.square.fill" : "1.square")
                }
                
                Button(action: {
                    shape = model.mnca.shapes[1]
                }) {
                    Image(systemName: shape === model.mnca.shapes[1] ? "2.square.fill" : "2.square")
                }
                
                Button(action: {
                    shape = model.mnca.shapes[2]
                }) {
                    Image(systemName: shape === model.mnca.shapes[2] ? "3.square.fill" : "3.square")
                }
            }
        }

        
#if os(macOS)
        .frame(minWidth: 400, idealWidth: 700, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
#endif
        
        .navigationTitle(shape != nil ? shape!.name: "")
        .animation(.linear)//, value: 1)
    }

    /// Returns the appropriate color for the given shape index, right now only black / white if 0 / 1
    func getColorForIndex(_ index: Int) -> Color {
        
        if let shape = shape {
            if shape.pixels17x17[index] == -1 {
                return .red
            } else
            if shape.pixels17x17[index] == 1 {
                return .white
            }
        }
        
        return .black
    }
}

