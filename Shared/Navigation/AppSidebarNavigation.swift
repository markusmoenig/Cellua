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
    @State private var presentingRewards: Bool = false
    @State private var selection: NavigationItem? = .shapes
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(tag: NavigationItem.shapes, selection: $selection) {
                    Text("Shapes")
                } label: {
                    Label("Shapes", systemImage: "square")
                }
                
                NavigationLink(tag: NavigationItem.rules, selection: $selection) {
                    Text("Rules")
                } label: {
                    Label("Rules", systemImage: "list.bullet")
                }
                
                NavigationLink(tag: NavigationItem.preview, selection: $selection) {
                    MetalView()
                } label: {
                    Label("Preview", systemImage: "list.bullet")
                }
            }
        }
    }
}
