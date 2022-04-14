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
            }
        }
        .onAppear(perform: loadData)
        .navigationTitle(playlistName)
    }
    
    // updates model's songs array with current playlists songs when view appears
    private func loadData() {
        model.songs = Array(songs)
    }
}
