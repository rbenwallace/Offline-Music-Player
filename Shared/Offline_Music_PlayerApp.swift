//
//  Offline_Music_PlayerApp.swift
//  Shared
//
//  Created by Ben Wallace on 2022-03-15.
//

import SwiftUI
import CoreData

@main
struct Offline_Music_PlayerApp: App {
    let persistenceController = PersistenceController.shared
    
    init(){
        do {
            let viewContext = persistenceController.container.viewContext
            let request = NSFetchRequest<Playlist>(entityName: "Playlist")
            let result = try viewContext.fetch(request) as [Playlist]
            if result.count < 1 {
                let mostPlayed = Playlist(context: viewContext)
                mostPlayed.timestamp = Date()
                mostPlayed.title = "Most Played"
                try viewContext.save()
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
