//
//  PlaylistView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-21.
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
    @State var song1 = false
    @State private var isImporting = false
    let playerManager = AudioPlayerManager()
    @State private var textEntered = ""
    @State private var showingAlert = false
    @State private var updateSong = Song()

    var body: some View {
        if showingAlert == true {
            CustomAlert(textEntered: $textEntered, showingAlert: $showingAlert, song: $updateSong, isPlaylist: true)
                .environment(\.managedObjectContext, viewContext)
        } else{
            NavigationView {
                List {
                    ForEach(playlists) { playlist in
                        NavigationLink {
                            if playlist.title != "Most Played"{
                                PlaylistSongsView(playlist: playlist)
                                    .environmentObject(model)
                            } else {
                                SmartSongsView(playlist.title!)
                                    .environmentObject(model)
                            }
                        } label: {
                            Text(playlist.title ?? "Unknown")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle("Playlists")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            self.showingAlert.toggle()
                            }) {
                            Image(systemName: "plus")
                            }
                    }
                    
                }
                Text("Select an item")
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if playlists[index].title != "Most Played"{
                    viewContext.delete(playlists[index])
                }
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
