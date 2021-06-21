//
//  AppSidebarNavigation.swift
//  Cellua
//
//  Created by Markus Moenig on 11/6/21.
//

import SwiftUI

struct AppSidebarNavigation: View {

    enum NavigationItem {
        case shapes
        case rules
        case library
        case preview
    }

    @EnvironmentObject private var model: Model
    @State private var selection: NavigationItem? = .shapes

    var body: some View {
        NavigationView {
            List {
                NavigationLink(tag: NavigationItem.shapes, selection: $selection) {
                    ShapeView()
                    
                    //let entity = CelluaEntity(context: managedObjectContext)
                } label: {
                    Label("Shapes", systemImage: "square")
                }
                
                NavigationLink(tag: NavigationItem.rules, selection: $selection) {
                    RuleView()
                } label: {
                    Label("Rules", systemImage: "list.bullet")
                }
                
                NavigationLink(tag: NavigationItem.preview, selection: $selection) {
                    LibraryView()
                } label: {
                    Label("Library", systemImage: "house")
                }
            }
        }
        
        .navigationTitle("Cellua")        
        .animation(.default)//, value: 1)
    }
}
