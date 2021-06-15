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
        case preview
        case settings
    }

    @EnvironmentObject private var model: Model
    @State private var selection: NavigationItem? = .shapes
    
    @State var previewText = "Hide Preview"
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(tag: NavigationItem.shapes, selection: $selection) {
                    ShapeList()
                } label: {
                    Label("Shapes", systemImage: "square")
                }
                
                NavigationLink(tag: NavigationItem.rules, selection: $selection) {
                    RuleList()
                } label: {
                    Label("Rules", systemImage: "list.bullet")
                }
                
                NavigationLink(tag: NavigationItem.preview, selection: $selection) {
                    MetalView()
                } label: {
                    Label("Preview", systemImage: "list.bullet")
                }
            }
            
            .navigationTitle("Cellua")
        }
        
        .animation(.default)//, value: 1)
    }
}
