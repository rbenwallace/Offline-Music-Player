//
//  SmartSongsView.swift
//  Offline Music Player (iOS)
//
//  Represents the view displayed when a smart playlist is selected from PlaylistView
//

import SwiftUI
import CoreData

struct SmartSongsView: View {
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // Fetch result of Song entities from core data database
    @FetchRequest private var songs: FetchedResults<Song>
    
    // name of current playlist
    private var playlistName: String

    // constructor for initializing playlistName and the songs fetch request
    init(playlistName: String) {
        self.playlistName = playlistName
        
        // creates request with a limit of only 10 Song entities, sorted by Song entities with the highest plays attribute
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Song.plays, ascending: false)
        ]
        request.predicate = NSPredicate(format: "plays > 0")
        request.fetchLimit = 10
        
        // executes the fetch request
        _songs = FetchRequest(fetchRequest: request)
        
    }

    // displays a list of song card views for each song in the playlist
    var body: some View {
        List {
            ForEach(songs) { song in
                SongCardView(song: song, fromPlaylist: true)
                    .environmentObject(model)
                
                // adds the song to the audio player's queue on swipe right
                .swipeActions(edge: .leading) {
                    Button {
                        model.queuedSongs.append(song)
                    } label: {
                        Label("Add to queue", systemImage: "plus.circle")
                    }
                    .tint(.green)
                }
            }
        }
        .onAppear(perform: loadData)
        .navigationTitle(playlistName)
        
        // adjusts view to include the bar player view when a song is playing
        if !self.model.isPlayerViewPresented && self.model.currentSong != nil {
            Spacer(minLength: 62)
        }
    }
    
    // updates model's songs array with current playlists songs when view appears
    private func loadData() {
        model.songs = Array(songs)
    }
}
