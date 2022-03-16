//
//  QueueView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-03-02.
//

import SwiftUI
import CoreData

struct QueueView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            List {
                ForEach(model.queuedSongs) { song in
                    Text(song.unwrappedTitle)
                }
                .onMove(perform: move)
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Queue")
            .toolbar{
                EditButton()
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        model.queuedSongs.move(fromOffsets: source, toOffset: destination)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                model.queuedSongs.remove(at: index)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
