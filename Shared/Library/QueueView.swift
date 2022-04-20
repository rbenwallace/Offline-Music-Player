//
//  QueueView.swift
//  Offline Music Player (iOS)
//
//  Represents the view which displays all Song entities that have been added to the queue, and allows for the user to manipulate the queue by deleting and rearranging Song entities 
//

import SwiftUI
import CoreData

struct QueueView: View {
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.queuedSongs) { song in
                    Text(song.title ?? "Unknown Song")
                        .lineLimit(2)
                        .padding(20)
                }
                .onMove(perform: move)
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Queue")
            .toolbar{
                EditButton()
            }
        }
        // adjusts view to include the bar player view when a song is playing
        .padding(.bottom, (!model.isPlayerViewPresented && model.currentSong != nil) ? 60: 0)
    }
    
    // allows user to move a song in the queue to a new queue destination
    func move(from source: IndexSet, to destination: Int) {
        model.queuedSongs.move(fromOffsets: source, toOffset: destination)
    }

    // deletes songs from the model's queue array
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                model.queuedSongs.remove(at: index)
            }
        }
    }
}
