//
//  LibraryView.swift
//  Cellua
//
//  Created by Markus Moenig on 21/6/21.
//

import SwiftUI

struct LibraryView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(
      entity: CelluaEntity.entity(),
      sortDescriptors: [
        NSSortDescriptor(keyPath: \CelluaEntity.name, ascending: true)
      ]
    ) var objects: FetchedResults<CelluaEntity>
    
    var body: some View {
        
        List {
            ForEach(objects, id: \.name) { object in
                object.name.map(Text.init)
                    .onTapGesture {
                        self.managedObjectContext.delete(object)
                        try! managedObjectContext.save()
                    }
            }
            //.onDelete(perform: deleteObject)
        }
        .navigationTitle("Library")
    }
    
    func deleteObject(at offsets: IndexSet) {
        offsets.forEach { index in

            let object = self.objects[index]
            self.managedObjectContext.delete(object)
        }
        try! managedObjectContext.save()
    }
}

