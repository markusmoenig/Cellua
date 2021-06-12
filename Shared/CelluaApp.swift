//
//  CelluaApp.swift
//  Shared
//
//  Created by Markus Moenig on 11/6/21.
//

import SwiftUI

@main
struct CelluaApp: App {
    
    @StateObject private var model = Model()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
