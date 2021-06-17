//
//  ContentView.swift
//  Shared
//
//  Created by Markus Moenig on 11/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var model: Model

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    
    var body: some View {
        
        #if os(iOS)
        if horizontalSizeClass == .compact {
            AppTabNavigation()
        } else {
            AppSidebarNavigation()
        }
        #else
        AppSidebarNavigation()
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
