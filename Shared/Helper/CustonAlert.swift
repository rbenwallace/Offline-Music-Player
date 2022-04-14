//
//  CustomAlert.swift
//  Offline Music Player (iOS)
//
//  This class represents a pop up alert that lets the user either create a playlist or rename s song
//

import SwiftUI
import CoreData

struct CustomAlert: View {
    // used to determine systems background color
    @Environment(\.colorScheme) var colorScheme
    
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // persistent storage context
    @Environment(\.managedObjectContext) private var viewContext
    
    // boolean of whether the alert was triggered from a playlist
    private var isPlaylist: Bool
    
    // binding string of the text entered, which will be initially displayed to the user in the alert
    @Binding private var textEntered: String
    
    // binding boolean of whether this current view should be displayed
    @Binding private var showingAlert: Bool
    
    // binding Song variable whos title is to be renamed
    @Binding private var updateSong: Song
    
    // constructor for call from PlaylistView which initializes local variables
    init(isPlaylist: Bool, textEntered: Binding<String>, showingAlert: Binding<Bool>){
        self.isPlaylist = isPlaylist
        self._textEntered = textEntered
        self._showingAlert = showingAlert
        self._updateSong = Binding.constant(Song())
    }
    
    // constructor for call from LibraryView which initializes local variables
    init(isPlaylist: Bool, textEntered: Binding<String>, showingAlert: Binding<Bool>, updateSong: Binding<Song>){
        self.isPlaylist = isPlaylist
        self._textEntered = textEntered
        self._showingAlert = showingAlert
        self._updateSong = updateSong
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Helper.primaryBackground)
            ZStack {
                // area that allows user to input text to fulfill alert
                RoundedRectangle(cornerRadius: 20)
                    .fill(Helper.secondaryBackground)
                VStack {
                    Spacer(minLength: 10)
                    
                    Text(isPlaylist ? "Playlist Name" : "Rename File")
                        .font(.title)
                        .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                    
                    Spacer(minLength: 0)
                    
                    TextField("Enter text", text: $textEntered)
                        .padding(5)
                        .background(Helper.tertiaryBackground)
                        .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                        .padding(.horizontal, 20)
                        
                    Spacer(minLength: 0)
                    
                    // options which let user either cancel the alert, or complet it with the text they entered
                    HStack(spacing: 80) {
                        Button("Cancel") {
                            self.showingAlert.toggle()
                        }
                        
                        Button("Ok") {
                            if self.textEntered != ""{
                                if isPlaylist {
                                    addPlaylist(playlistName: textEntered)
                                } else {
                                    renameSong(newTitle: textEntered)
                                }
                            }
                            self.textEntered = ""
                            self.showingAlert.toggle()
                        }
                    }
                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                    .padding(10)
                    
                    Spacer(minLength: 0)
                }
            }
            .frame(width: 300, height: 200)
        }
    }
    
    // renames inputted song in app's document directory and in the database
    private func renameSong(newTitle: String) {
        do {
            // renames song in app's document directory
            try FileManager.default.moveItem(at: Helper.getDocumentsDirectory().appendingPathComponent(self.updateSong.title!), to: Helper.getDocumentsDirectory().appendingPathComponent(textEntered + self.updateSong.title![self.updateSong.title!.lastIndex(of: ".")!...]))
            
            // renames song in database
            self.updateSong.title = textEntered + self.updateSong.title![self.updateSong.title!.lastIndex(of: ".")!...]
            try viewContext.save()
        } catch {
            print("Could not remame song: \(error.localizedDescription)")
        }
    }

    // creates and saves new playlist
    private func addPlaylist(playlistName: String) {
        withAnimation {
            // initializes new playlist's attributes
            let newPlaylist = Playlist(context: viewContext)
            newPlaylist.timestamp = Date()
            newPlaylist.title = playlistName
            
            // saves new playlist in database
            do {
                try viewContext.save()
            } catch {
                // if a playlist already exists with the same title delete the newly created playlist
                viewContext.delete(newPlaylist)
                print("Playlist could not be added: \(error.localizedDescription)")
            }
        }
    }
}
