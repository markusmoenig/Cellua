//
//  ShapeView.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import SwiftUI

struct ShapeView: View {
    
    var shape               : Shape
    
    @EnvironmentObject private var model: Model
    @State var currentIndex : Int? = nil
    
    init(shape: Shape)
    {
        self.shape = shape
    }
    
    var body: some View {
                    
        let columns = [
            GridItem(.adaptive(minimum: 20), spacing: 1)
        ]
        
        VStack {
            
            Spacer()

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<17*17) { index in
                    ZStack {
                        Rectangle()
                            .fill(getColorForIndex(index))
                            .frame(width: 20, height: 20)
                            .onTapGesture(perform: {
                                
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
                                
                                currentIndex = nil

                            })
                            .padding(0)
                        
                        
                        if index == currentIndex {                            
                        }
                    }
                }
            }
            .frame(maxWidth: 17*20 + 16)
            
            Spacer()
            
            if model.showPreview {
                MetalView()
                    .frame(maxHeight: 100)
            }

        }
        
#if os(macOS)
        .frame(minWidth: 400, idealWidth: 700, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
#endif
        
        .navigationTitle(shape.name)
        .animation(.default)//, value: 1)
    }
    
    func getColorForIndex(_ index: Int) -> Color {
        
        if shape.pixels17x17[index] == -1 {
            return .red
        } else
        if shape.pixels17x17[index] == 1 {
            return .white
        }
        
        return .black
    }
}

