//
//  CelluaApp.swift
//  Shared
//
//  Created by Markus Moenig on 11/6/21.
//

import SwiftUI

@main
struct CelluaApp: App {
    
    let persistenceController = PersistenceController.shared

    @Environment(\.scenePhase) var scenePhase

    @StateObject private var model = Model()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
