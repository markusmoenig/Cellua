//
//  ContentView.swift
//  Shared
//
//  Created by Markus Moenig on 11/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var model: Model

    var body: some View {
        AppSidebarNavigation()
        
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.model.renderer.isStarted = true
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
