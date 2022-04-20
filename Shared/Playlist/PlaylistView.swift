//
//  PlaylistView.swift
//  Offline Music Player (iOS)
//
//  This view class displays all the user's playlists, and allows them to add more playlists or enter a playlist
//

import SwiftUI
import CoreData

struct PlaylistView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.timestamp, ascending: true)],
        animation: .default)
    private var playlists: FetchedResults<Playlist>
    @State private var showingAlert = false
    @State private var isImporting = false
    @State private var textEntered = ""
    
    var body: some View {
        if showingAlert == true {
            CustomAlert(isPlaylist: true, textEntered: $textEntered, showingAlert: $showingAlert)
        } else{
            NavigationView {
                List {
                    ForEach(playlists) { playlist in
                        NavigationLink(destination: {
                            if playlist.title != "Most Played"{
                                PlaylistSongsView(playlist: playlist)
                                    .environmentObject(model)
                            } else {
                                SmartSongsView(playlistName: playlist.title!)
                                    .environmentObject(model)
                            }
                        }, label: {
                            PlaylistCardView(playlist: playlist)
                        })
                    }
                    .onDelete(perform: deleteSongs)
                }
                .navigationBarTitle(Text("Playlists"), displayMode: .automatic)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            showingAlert.toggle()
                            }) {
                            Image(systemName: "plus")
                            }
                    }
                    
                }
            }
            // adjusts view to include the bar player view when a song is playing
            .padding(.bottom, (!model.isPlayerViewPresented && model.currentSong != nil) ? 60: 0)
        }
    }

    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if playlists[index].title != "Most Played"{
                    viewContext.delete(playlists[index])
                }
            }
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete playlist \(error.localizedDescription)")
            }
        }
    }
}
