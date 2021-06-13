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
            GridItem(.adaptive(minimum: 30), spacing: 1)
        ]
        
        VStack {
            
            Spacer()

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<81) { index in
                    ZStack {
                        Rectangle()
                            .fill(getColorForIndex(index))
                            .frame(width: 30, height: 30)
                            .onTapGesture(perform: {
                                
                                if shape.pixels9x9[index] == 1 {
                                    shape.pixels9x9[index] = 0
                                    model.renderer.needsReset = true
                                    currentIndex = index
                                } else
                                if shape.pixels9x9[index] == 0 {
                                    shape.pixels9x9[index] = 1
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
            .frame(maxWidth: 278)
            
            Spacer()
            
            if model.showPreview {
                MetalView()
                    .frame(maxHeight: 100)
            }

        }
        
#if os(macOS)
        .frame(minWidth: 300, idealWidth: 700, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
#endif
        
        .navigationTitle(shape.name)
        .animation(.default)//, value: 1)

    }
    
    func getColorForIndex(_ index: Int) -> Color {
        
        if shape.pixels9x9[index] == -1 {
            return .red
        } else
        if shape.pixels9x9[index] == 1 {
            return .black
        }
        
        return .white
    }
}

