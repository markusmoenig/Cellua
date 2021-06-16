//
//  AppTabNavigation.swift
//  Cellua
//
//  Created by Markus Moenig on 15/6/21.
//

import SwiftUI

struct AppTabNavigation: View {

    enum Tab {
        case shapes
        case rules
        case preview
    }

    @State private var selection: Tab = .shapes

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                ShapeView()
            }
            .tabItem {
                let menuText = Text("Shapes", comment: "Shape menu tab title")
                Label {
                    menuText
                } icon: {
                    Image(systemName: "list.bullet")
                }.accessibility(label: menuText)
            }
            .tag(Tab.shapes)
            
            NavigationView {
                RuleView()
            }
            .tabItem {
                Label {
                    Text("Rules",
                         comment: "Rules smoothies tab title")
                } icon: {
                    Image(systemName: "heart.fill")
                }
            }
            .tag(Tab.rules)
            
            NavigationView {
                MetalView()
            }
            .tabItem {
                Label {
                    Text("Preview",
                         comment: "Preview rewards tab title")
                } icon: {
                    Image(systemName: "seal.fill")
                }
            }
            .tag(Tab.preview)
        }
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppTabNavigation()
    }
}
