//
//  ShapeView.swift
//  Cellua
//
//  Created by Markus Moenig on 13/6/21.
//

import SwiftUI

struct ShapeView: View {
        
    @Environment(\.managedObjectContext) var managedObjectContext

    @EnvironmentObject private var model    : Model
    @State var currentIndex                 : Int? = nil
    
    @State var shape                        : Shape? = nil
    
    @State var showShapePopover             = false

    @State var sizeValue                    : Double = 3
    @State var sizeValueText                = "3"
    
    @State var ringValue                    : Double = 0
    @State var ringValueText                = "0"

    init()
    {
    }
    
    var body: some View {
                    
        let columns = [
            GridItem(.adaptive(minimum: 20), spacing: 1)
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
                            .frame(maxWidth: 18 * 20 + 16, maxHeight: 18 * 20 + 16)
                                        
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
                        //.background(Color.gray)
                        .frame(maxWidth: 17 * 20 + 16)
                    }
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
            
            ToolbarItemGroup(placement: .automatic) {
                
                Button(action: {
                    fill(0)
                }) {
                    Image(systemName: "square")
                }
                
                Button(action: {
                    fill(1)
                }) {
                    Image(systemName: "square.fill")
                }
                
                Button(action: {
                    showShapePopover = true
                }) {
                    Image(systemName: "circle")
                }
            }
            
            ToolbarItemGroup(placement: .automatic) {
                
                Button(action: {
                    
                    
                    let object = CelluaEntity(context: managedObjectContext)
                    
                    object.name = "Yo"
                    
                    try! managedObjectContext.save()
                    
                    let request = CelluaEntity.fetchRequest()
                    let objects = try! managedObjectContext.fetch(request)

                    print("here")
                    objects.forEach { ca in
                        
                        guard let name = ca.name else {
                            return
                        }

                        print("testing", name)
                    }
                    
                }) {
                    Image(systemName: "square")
                }
            }
        }
        
        // Edit Node name
        .popover(isPresented: self.$showShapePopover,
                 arrowEdge: .top
        ) {
            VStack(alignment: .leading) {
                
                Menu("Shape: Circle") {
                    Button(action: {
                    }) {
                        Text("Circle")
                    }
                    
                    Button(action: {
                    }) {
                        Text("Box")
                    }
                }
                
                Text("Size")
                    .padding(.top, 10)

                HStack {
                    Slider(value: Binding<Double>(get: {sizeValue}, set: { v in
                        sizeValue = v
                        sizeValueText = String(Int(v))
                    }), in: Double(1)...Double(8))//, step: Double(parameter.step))
                    Text(sizeValueText)
                        .frame(maxWidth: 40)
                }
                
                Text("Ring")
                    .padding(.top, 10)

                HStack {
                    Slider(value: Binding<Double>(get: {ringValue}, set: { v in
                        ringValue = v
                        ringValueText = String(Int(v))
                    }), in: Double(1)...Double(8))//, step: Double(parameter.step))
                    Text(ringValueText)
                        .frame(maxWidth: 40)
                }
                
                HStack {
                    Button("Add", action: {
                        addCircle(Int(sizeValue), ring: Int(ringValue))
                    })
                    Button("Subtract", action: {
                        addCircle(Int(sizeValue), ring: Int(ringValue), subtract: true)
                    })
                }
                .padding(.top, 10)

            }
            .frame(minWidth: 250)
            .padding()
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
                return .red.opacity(0.6)
            } else
            if shape.pixels17x17[index] == 1 {
                return .white.opacity(0.6)
            }
        }
        
        return .black.opacity(0.6)
    }
    
    /// Adds a circle to the shape
    func addCircle(_ size: Int, ring: Int, subtract: Bool = false)
    {
        currentIndex = 2

        for j in 0..<17 {
            for i in 0..<17 {
                
                if j == 8 && i == 8 {
                    continue
                }
                
                let uv = float2(Float(i), Float(j)) - float2(8,8)
                
                let d = round(length(uv) - Float(size + 1))
                
                if ring == 0 {
                    if d < 0.0 {
                        shape!.pixels17x17[j * 17 + i] = subtract ? 0 : 1
                    }
                } else {
                    //d = abs(d) - Float(ringValue)
                    if d < 0.0 && d > -Float(ringValue) {
                        shape!.pixels17x17[j * 17 + i] = subtract ? 0 : 1
                    }
                }
            }
        }
        
        currentIndex = nil
    }
    
    ///  Fills the shape
    func fill(_ value: Int32)
    {
        currentIndex = 2

        for j in 0..<17 {
            for i in 0..<17 {
                
                if j == 8 && i == 8 {
                    continue
                }
                
                shape!.pixels17x17[j * 17 + i] = value
            }
        }
        
        currentIndex = nil
    }
}

