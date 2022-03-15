//
//  Offline_Music_PlayerApp.swift
//  Shared
//
//  Created by Ben Wallace on 2022-03-15.
//

import SwiftUI

@main
struct Offline_Music_PlayerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
