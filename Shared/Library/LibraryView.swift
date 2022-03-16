//
//  SongView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-21.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isImporting = false
    @State var showingAlert = false
    @State var textEntered = ""
    @State var updateSong = Song()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Song.timestamp, ascending: false)],
        animation: .default)
    private var songs: FetchedResults<Song>

    var body: some View {
        if showingAlert == true {
            CustomAlert(textEntered: $textEntered, showingAlert: $showingAlert, song: $updateSong, isPlaylist: false)
                .environment(\.managedObjectContext, viewContext)
        } else{
            NavigationView {
                List {
                    ForEach(songs) { song in
                        SongCardView(showingAlert: $showingAlert, textEntered: $textEntered, updateSong: $updateSong, song: song)
                            .environmentObject(model)
                            .onTapGesture {
                                self.model.playSong(id: song.id!, fromPlaylist: false, songTitle: song.title!)
                            }
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
                .navigationTitle("Library")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                                    isImporting = true
                                }) {
                                Image(systemName: "plus")
                                }
                    }
                    
                }
                Text("Select an item")
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                if case .success = result {
                    do {
                        let aURL: URL = try result.get().first!
                        if aURL.startAccessingSecurityScopedResource() {
                            addItem(songUrl: aURL)
                            aURL.stopAccessingSecurityScopedResource()
                        }
                    } catch {
                        let nsError = error as NSError
                        fatalError("File Import Error \(nsError), \(nsError.userInfo)")
                    }
                } else {
                    print("File Import Failed")
                }
            }
        }
    }
    
    func loadData() {
        self.model.songs = Array(songs)
    }

    private func addItem(songUrl: URL) {
        withAnimation {
            let newSong = Song(context: viewContext)
            newSong.id = UUID()
            newSong.timestamp = Date()
            newSong.plays = 0
            newSong.title = songUrl.lastPathComponent
            let fileData = try? Data.init(contentsOf: songUrl)
            do {
                try fileData?.write(to: self.model.getDocumentsDirectory().appendingPathComponent(songUrl.lastPathComponent))
            } catch {
                print(error.localizedDescription)
            }
            do {
                try viewContext.save()
                let fetchRequest: NSFetchRequest<Song> = Song.fetchRequest()
                self.model.songs = try self.viewContext.fetch(fetchRequest) as [Song]
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteSong(song: Song) {
        withAnimation {
            if model.audioPlayer.currentItem != nil {
                let deleteArr: [String] = [song.title!]
                model.updateDeleted(deleted: deleteArr)
                if let idx = model.playlistSongs.firstIndex(where: { $0.title! == song.title! }) {
                    if model.currentSongIndex > idx {
                        model.currentSongIndex -= 1
                    } else if model.currentSongIndex == idx {
                        model.audioPlayer.advanceToNextItem()
                    }
                    model.playlistSongs.remove(at: idx)
                }
            }
            do {
                try FileManager.default.removeItem(at: self.model.getDocumentsDirectory().appendingPathComponent(song.title!))
            } catch {
                print("Could not delete file: \(error)")
            }
            viewContext.delete(song)
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            self.model.songs = Array(songs)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            deleteSong(song: songs[index])
        }
    }
}
