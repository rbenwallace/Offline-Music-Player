//
//  SongCardView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-03-05.
//

import SwiftUI

struct SongCardView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showingAlert: Bool
    @Binding var textEntered: String
    @Binding var updateSong: Song
    
    public var song: Song
    
    var body: some View {
        HStack {
            Text(song.unwrappedTitle)
            
            Spacer()
            
            Menu {
                Button(action: { editSongTitle() }, label: { Text("Edit Song Title") })
                Button(action: { shareSong() }, label: { Text("Share Song") })
                Button("Cancel", action: cancelMenu)
            } label: {
                Label("", systemImage: "ellipsis.circle")
            }
        }
    }
    
    func editSongTitle() {
        updateSong = song
        textEntered = String(song.title![..<song.title!.lastIndex(of: ".")!])
        showingAlert.toggle()
    }
    
    func shareSong() {
        let activityVC = UIActivityViewController(activityItems: [model.getDocumentsDirectory().appendingPathComponent(song.title!)], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func cancelMenu() {}
}
