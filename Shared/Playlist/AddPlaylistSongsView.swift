//
//  AddPlaylistSongsView.swift
//  Offline Music Player (iOS)
//
//  This view class represents the view that allows users to select and add songs to one of their playlists
//

import SwiftUI
import CoreData

struct AddPlaylistSongsView: View {
    // used to determine systems background color
    @Environment(\.colorScheme) var colorScheme
    
    // persistent storage context
    @Environment(\.managedObjectContext) private var viewContext
    
    // binding boolean which determines whether to display this current view
    @Binding private var isAddingSongs: Bool
    
    // the playlist which songs will be added to
    private var playlist: Playlist
    
    // available songs to be added into playlist
    private var availableSongs: [Song]
    
    // chosen songs to add to playlist
    @State private var selections: [Song] = [Song]()
    
    // constructor to initialize local variables
    init(isAddingSongs: Binding<Bool>, availableSongs: [Song], playlist: Playlist) {
        self._isAddingSongs = isAddingSongs
        self.availableSongs = availableSongs
        self.playlist = playlist
    }

    // displays list of songs that can be added to the passed playlist, allows users to click the songs they want to add
    var body: some View {
        List {
            ForEach(self.availableSongs, id: \.self) { item in
                Button(action: {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }) {
                    HStack {
                        Text(item.title!)
                        // adds checkmark when song is selected
                        if selections.contains(item) {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                }
            }
        }
        .toolbar {
            // brings user back to PlaylistSongsView without adding songs to playlist
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.isAddingSongs.toggle()
                }) {
                    Text("Cancel")
                }
            }
            // adds chosen songs from selections to the current playlist, brings user back to PlaylistSongsView
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // adds songs to playlist
                    for s in self.selections {
                        self.playlist.addToSongs(s)
                    }
                    // saves changes to viewContext
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to add songs to playlist: \(error.localizedDescription)")
                    }
                    // updates isAddingSongs to false
                    self.isAddingSongs.toggle()
                }) {
                    Text("Add")
                }
            }
            
        }
    }
}
