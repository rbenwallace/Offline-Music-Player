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
    
    init(){
        // Adds a smart playlist called most played on app's first launch
        do {
            let viewContext = persistenceController.container.viewContext
            
            // make request to see how many playlists currently exist
            let request = NSFetchRequest<Playlist>(entityName: "Playlist")
            let result = try viewContext.fetch(request) as [Playlist]
            
            // if there are no playlists, create one which will be represented as a smart playlist
            if result.count < 1 {
                let mostPlayed = Playlist(context: viewContext)
                mostPlayed.timestamp = Date()
                mostPlayed.title = "Most Played"
                try viewContext.save()
            }
        } catch let error as NSError {
            print("Failed to make smart playlist or check if one exists: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
