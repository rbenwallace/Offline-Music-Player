//
//  LibraryView.swift
//  Offline Music Player (iOS)
//
//  Represents the view which displays all Song entities the user has saved in this app's documents directory
//

import SwiftUI
import CoreData

struct LibraryView: View {
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // persistent storage context
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch request for getting all Song entities
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Song.timestamp, ascending: false)],
        animation: .default)
    private var songs: FetchedResults<Song>
    
    // state boolean for determining whether to display the CustomAlert view
    @State private var showingAlert = false
    
    // state boolean for determining whether to display the file importer
    @State private var isImporting = false
    
    // state String to manage the string to be passed to CustomAlert view iif the user wants to edit a song title
    @State private var textEntered = ""
    
    // state Song entity to represent which song's title is to be updated
    @State private var updateSong = Song()

    var body: some View {
        // displays the Custom Alert View
        if self.showingAlert == true {
            CustomAlert(isPlaylist: false, textEntered: self.$textEntered, showingAlert: self.$showingAlert, updateSong: self.$updateSong)
                .environment(\.managedObjectContext, viewContext)
        } else{
            // Displays a list of SongCardView views to represent every Song entity
            NavigationView {
                List {
                    ForEach(songs) { song in
                        SongCardView(song: song, fromPlaylist: false, alertShowing: self.$showingAlert, textEntered: self.$textEntered, updateSong: self.$updateSong)
                            .environmentObject(model)
                            // lets user add a song to the audio player's queue by swiping right
                            .swipeActions(edge: .leading) {
                                Button {
                                    model.queuedSongs.append(song)
                                    print("Queue Length: ", model.queuedSongs.count)
                                } label: {
                                    Label("Add to queue", systemImage: "plus.circle")
                                }
                                .tint(.green)
                            }
                            // allows user to delete a song from the database by swiping left
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
                .navigationTitle("Library")
                .toolbar {
                    // allows user to delete multiple songs at once
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    // allows user to import songs from cloud platforms and locally
                    ToolbarItem {
                        Button(action: {
                                    isImporting = true
                                }) {
                                Image(systemName: "plus")
                                }
                    }
                    
                }
            }
            .onAppear(perform: loadData)
            // file importer for importing files
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                if case .success = result {
                    do {
                        // if a file was chosen, get access to the file
                        let aURL: URL = try result.get().first!
                        if aURL.startAccessingSecurityScopedResource() {
                            // once granted access to read and write the file, download the file if necessary
                            if !FileManager.default.fileExists(atPath: aURL.path) {
                                var error: NSError?
                                // Force file to download if from Cloud platform
                                NSFileCoordinator().coordinate(
                                    readingItemAt: aURL, options: .forUploading, error: &error) { _ in }
                            }
                            // add song to core data database
                            addItem(songUrl: aURL)
                            // release file access once done
                            aURL.stopAccessingSecurityScopedResource()
                        }
                    } catch {
                        print("File Import Error: \(error.localizedDescription)")
                        self.isImporting = false
                    }
                } else {
                    print("File Import Failed")
                    self.isImporting = false
                }
            }
        }
    }
    
    // update model's songs array when view appears
    private func loadData() {
        self.model.songs = Array(songs)
    }

    // adds song to core data database
    private func addItem(songUrl: URL) {
        withAnimation {
            // set song entity attributes
            let newSong = Song(context: viewContext)
            newSong.id = UUID()
            newSong.timestamp = Date()
            newSong.plays = 0
            newSong.title = songUrl.lastPathComponent
            
            // initialize songs file contents and write it to the app's document directory
            let fileData = try? Data.init(contentsOf: songUrl)
            do {
                try fileData?.write(to: Helper.getDocumentsDirectory().appendingPathComponent(songUrl.lastPathComponent))
            } catch {
                // song could not be written to app's document directory
                viewContext.delete(newSong)
                print("Song file could not be written to app's document directory: \(error.localizedDescription)")
                return
            }
            do {
                // save persistent storage context
                try viewContext.save()
            } catch {
                // catches core data not being able to save the song to the database
                viewContext.delete(newSong)
                print("Song could not be added: \(error.localizedDescription)")
                return
            }
            // update model's songs array with new song
            self.model.songs = Array(songs)
        }
    }

    // deletes a song from all playlists and the core data database, and view context saves the database
    private func deleteSong(song: Song) {
        withAnimation {
            // updates audio player's queue to handle song being deleted
            self.model.deleteSong(deleteSong: song.title!)
            do {
                // removes the song file from app's document directory
                try FileManager.default.removeItem(at: Helper.getDocumentsDirectory().appendingPathComponent(song.title!))
            } catch {
                // song file could not be deleted from app's document directory
                print("Could not delete song from app's document directory")
                return
            }
            // view context deletes the song then saves
            viewContext.delete(song)
            do {
                try viewContext.save()
            } catch {
                // catches core data not being able to delete the song to the database
                print("Song could not be deleted")
                return
            }
            // model's songs array is updated
            self.model.songs = Array(songs)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            deleteSong(song: songs[index])
        }
    }
}
