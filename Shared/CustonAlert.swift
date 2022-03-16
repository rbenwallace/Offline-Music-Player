//
//  Alert.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-22.
//

import SwiftUI
import CoreData

struct CustomAlert: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var textEntered: String
    @Binding var showingAlert: Bool
    @Binding var song: Song
    public var isPlaylist: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
            VStack {
                Divider()
                
                Text(isPlaylist ? "Playlist Name" : "Rename File")
                    .font(.title)
                    .foregroundColor(.black)
                
                Divider()
                
                TextField("Enter text", text: $textEntered)
                    .textCase(.uppercase)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    
                    
                Divider()
                
                HStack(spacing: 80) {
                    Button("Cancel") {
                        self.showingAlert.toggle()
                    }
                    
                    Button("Ok") {
                        if self.textEntered != ""{
                            if isPlaylist {
                                addItem(playlistName: textEntered)
                            } else {
                                renameSong(inSong: song, newTitle: textEntered)
                                song = Song()
                            }
                            self.textEntered = ""
                        }
                        self.showingAlert.toggle()
                    }
                }
                .padding(30)
            }
        }
        .frame(width: 300, height: 200)
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    private func renameSong(inSong: Song, newTitle: String) {
        do {
            try FileManager.default.moveItem(at: getDocumentsDirectory().appendingPathComponent(song.title!), to: getDocumentsDirectory().appendingPathComponent(textEntered + song.title![song.title!.lastIndex(of: ".")!...]))
            song.title = textEntered + song.title![song.title!.lastIndex(of: ".")!...]
            try viewContext.save()
        } catch let error as NSError {
            print(error)
        }
    }

    private func addItem(playlistName: String) {
        withAnimation {
            let newItem = Playlist(context: viewContext)
            newItem.timestamp = Date()
            newItem.title = playlistName
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
