//
//  PlaylistSongsView.swift
//  Offline Music Player (iOS)
//
//  Represents the view displayed when a normal playlist is selected from PlaylistView
//

import SwiftUI
import CoreData

struct PlaylistSongsView: View {
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // persistent storage view context which allows for saving/deleting new entities to the database
    @Environment(\.managedObjectContext) private var viewContext
    
    // playlist entity to represent the current playlist
    private var playlist: Playlist
    
    // state boolean which keeps track of whether or not to display the AddPlaylistSongsView view
    @State private var isAddingSongs = false
    
    // contstructor to initialize the current playlist
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    var body: some View {
        // displays the AddPlaylistSongsView view if the isAddingSongs state is true
        if isAddingSongs == true {
            AddPlaylistSongsView(isAddingSongs: $isAddingSongs, availableSongs: addableSongs(), playlist: playlist)
        } else {
            // displays a list of song card views of each song in the playlist
            List {
                ForEach(model.songs) { song in
                    SongCardView(song: song, fromPlaylist: true)
                        .environmentObject(model)
                    // adds the song to the audio player's queue on swipe right
                    .swipeActions(edge: .leading) {
                        Button {
                            model.queuedSongs.append(song)
                            print("Queue Length: ", model.queuedSongs.count)
                        } label: {
                            Label("Add to queue", systemImage: "plus.circle")
                        }
                        .tint(.green)
                    }
                    // deletes the song from the playlist on swipe left
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
                // simpler way users can delete songs
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                // allows users to add songs to the current playlist
                ToolbarItem {
                    Button(action: {
                        isAddingSongs.toggle()
                        }) {
                        Image(systemName: "plus")
                        }
                }
                
            }
        }
    }
    
    // updates the model's songs array with current playlist's songs when the view appear
    private func loadData() {
        self.model.songs = self.playlist.songArray
    }
    
    // generates a list of all the songs not currently in the current playlist
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
            print("addableSongs() - Failed to fetch song entities: \(error.localizedDescription)")
        }
        return returnArr
    }

    // adds an array of songs into the current playlist and view context saves the playlist
    private func addItem(songArr: [Song]) {
        withAnimation {
            for s in songArr {
                self.playlist.addToSongs(s)
            }
            do {
                try viewContext.save()
            } catch {
                print("Failed to add songs to playlist: \(error.localizedDescription)")
                return 
            }
            // updates the model's songs array with the current playlist's new songs
            self.model.songs = self.playlist.songArray
        }
    }
    
    // deletes a song from the current playlist and view context saves the playlist
    private func deleteSong(song: Song) {
        withAnimation {
            self.playlist.removeFromSongs(song)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete songs from playlst: \(error.localizedDescription)")
                return
            }
            // updates the model's songs array with the current playlist's new songs
            self.model.songs = self.playlist.songArray
        }
    }

    // removes multiple songs from the playlist
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            deleteSong(song: self.playlist.songArray[index])
        }
    }
}
