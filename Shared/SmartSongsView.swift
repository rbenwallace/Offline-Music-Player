//
//  SmartPlaylistView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-03-08.
//

import SwiftUI
import CoreData

struct SmartSongsView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var songs: FetchedResults<Song>
    public var playlistName: String

    init(_ playlistName: String) {
        self.playlistName = playlistName
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Song.plays, ascending: false)
        ]
        request.predicate = NSPredicate(format: "plays > 0")
        request.fetchLimit = 10
        _songs = FetchRequest(fetchRequest: request)
        
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(songs) { song in
                    NavigationLink(song.unwrappedTitle, destination: PlayerView(songId: song.id!, fromPlaylist: true, songTitle: song.title!)
                                    .environmentObject(model)
                    )
                }
            }
            .onAppear(perform: loadData)
            .navigationTitle(playlistName)
        }
    }
    
    private func loadData() {
        model.songs = Array(songs)
    }
}
