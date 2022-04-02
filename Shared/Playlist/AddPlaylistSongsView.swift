//
//  AddPlaylistSongsView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-26.
//

import SwiftUI
import CoreData

struct AddPlaylistSongsView: View {
    // persistent storage context
    @Environment(\.managedObjectContext) private var viewContext
    
    // binding boolean which determines whether to display this current view
    @Binding private var isAddingSongs: Bool
    
    // the playlist which songs will be added to
    private var playlist: Playlist
    
    // available songs to be added into playlist
    private var availableSongs: [Song]
    
    // chosen songs to add to playlist
    @State private var selections: [Song]
    
    // constructor to initialize local variables
    init(isAddingSongs: Binding<Bool>, availableSongs: [Song], playlist: Playlist) {
        self._isAddingSongs = isAddingSongs
        self.availableSongs = availableSongs
        self.selections = []
        self.playlist = playlist
    }

    // displays list of songs that can be added to the passed playlist, allows users to click the songs they want to add
    var body: some View {
        List {
            ForEach(self.availableSongs, id: \.self) { item in
                MultipleSelectionRow(title: item.title!, isSelected: self.selections.contains(where: { $0.id == item.id })) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
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

// represents each row in the list of songs, allowing users to select and deselect the row
struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
            .foregroundColor(.white)
        }
    }
}
