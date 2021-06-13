//
//  ShapeList.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import SwiftUI

struct ShapeList: View {
    
    enum ShapeItem {
        case shapeA
        case shapeB
        case shapeC
        case shapeD
    }
    
    @EnvironmentObject private var model: Model
    
    @State private var selection: ShapeItem? = .shapeA

    var body: some View {
        NavigationView {
            List {
                
                NavigationLink(tag: ShapeItem.shapeA, selection: $selection) {
                    ShapeView(shape: model.mnca.shapes[0])
                } label: {
                    //SmoothieRow(smoothie: smoothie)
                    //Text(shape.name)
                    Label("Shape A", systemImage: "square")
                }
                
                NavigationLink(tag: ShapeItem.shapeB, selection: $selection) {
                    ShapeView(shape: model.mnca.shapes[1])
                } label: {
                    //SmoothieRow(smoothie: smoothie)
                    //Text(shape.name)
                    Label("Shape B", systemImage: "square")
                }
                
                NavigationLink(tag: ShapeItem.shapeC, selection: $selection) {
                    ShapeView(shape: model.mnca.shapes[2])
                } label: {
                    //SmoothieRow(smoothie: smoothie)
                    //Text(shape.name)
                    Label("Shape C", systemImage: "square")
                }
            }
        }
        .navigationTitle("Shapes")
    }
}
