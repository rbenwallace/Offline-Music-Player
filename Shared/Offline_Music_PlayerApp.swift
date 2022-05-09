//
//  Offline_Music_PlayerApp.swift
//  
//  The main file of the app that is excecuted on launch 
//

import SwiftUI
import CoreData

@main
struct Offline_Music_PlayerApp: App {
    // creates the controller for persistent storage within the app
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
