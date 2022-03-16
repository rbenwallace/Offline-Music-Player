//
//  SongView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-21.
//

import SwiftUI
import CoreData

struct PlaylistSongsView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext
    public var playlist: Playlist
    @State private var isAdding = false

    var body: some View {
        if isAdding == true {
            AddPlaylistSongsView(isAdding: $isAdding, availableSongs: addableSongs(), playlist: playlist)
                .environmentObject(model)
        } else {
            NavigationView {
                List {
                    ForEach(model.songs) { song in
                        NavigationLink(song.unwrappedTitle, destination: PlayerView(songId: song.id!, fromPlaylist: true, songTitle: song.title!)
                                        .environmentObject(model)
                        )
                        .swipeActions(edge: .leading) {
                            Button {
                                model.queuedSongs.append(song)
                                print("Queue Length: ", model.queuedSongs.count)
                            } label: {
                                Label("Add to queue", systemImage: "plus.circle")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                deleteSong(song: song)
                            } label: {
                                Label("Delete Song", systemImage: "minus.circle")
                            }
                            .tint(.red)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .onAppear(perform: loadData)
                .navigationTitle(self.playlist.title!)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            isAdding.toggle()
                            }) {
                            Image(systemName: "plus")
                            }
                    }
                    
                }
                Text("Select an item")
            }
        }
    }
    
    private func loadData() {
        self.model.songs = self.playlist.songArray
    }
    
    private func addableSongs() -> [Song]{
        var returnArr: [Song] = []
        let currSongs = self.playlist.songArray
        let fetchRequest = NSFetchRequest<Song>(entityName: "Song")
        do {
            let allSongs: [Song] = try viewContext.fetch(fetchRequest)
            for s in allSongs {
                if !currSongs.contains(where: { $0.id == s.id }) {
                    returnArr.append(s)
                }
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return returnArr
    }

    private func addItem(songArr: [Song]) {
        withAnimation {
            for s in songArr {
                self.playlist.addToSongs(s)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            self.model.songs = self.playlist.songArray
        }
    }
    
    private func deleteSong(song: Song) {
        withAnimation {
            self.playlist.removeFromSongs(song)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            self.model.songs = self.playlist.songArray
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            deleteSong(song: self.playlist.songArray[index])
        }
    }
}
