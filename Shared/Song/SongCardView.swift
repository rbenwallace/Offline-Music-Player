//
//  SongCardView.swift
//  Offline Music Player (iOS)
//
//  This view represents a view of an individual song, which is displayed in library views and playlist views
//

import SwiftUI

struct SongCardView: View {
    // used to determine systems background color
    @Environment(\.colorScheme) var colorScheme
    
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // song which this song card view represents
    private var song: Song
    
    // whether or not this song is being showed in a playlist
    private var fromPlaylist: Bool
    
    // Binding boolean variable which controls whether or not the CustomAlert view should be shown
    @Binding private var alertShowing: Bool
    
    // Binding string which will be passed to CustomAlert if  the alertShowing boolean becomes true
    @Binding private var textEntered: String
    
    // Binding Song variable which will be passed to CustomAlert if the alertShowing boolean becomes true
    @Binding private var updateSong: Song
    
    // Playlist song card constructor
    init(song: Song, fromPlaylist: Bool){
        self.song = song
        self.fromPlaylist = fromPlaylist
        self._alertShowing = Binding.constant(true)
        self._textEntered = Binding.constant("")
        self._updateSong = Binding.constant(Song())
    }
    
    // Library song card constructor
    init(song: Song, fromPlaylist: Bool, alertShowing: Binding<Bool>, textEntered: Binding<String>, updateSong: Binding<Song>){
        self.song = song
        self.fromPlaylist = fromPlaylist
        self._alertShowing = alertShowing
        self._textEntered = textEntered
        self._updateSong = updateSong
    }
    
    var body: some View {
        Button(action: { model.playSong(id: song.id!, fromPlaylist: fromPlaylist, songTitle: song.title!) }) {
            VStack {
                Spacer(minLength: 0)
                
                HStack {
                    // Card view which displays a preset image, the song name, and the author
                    HStack {
                        Image(uiImage: UIImage(named: "song_cover") ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.trailing, 5)
                        VStack(alignment: .leading) {
                            if (song.title != nil) && (song.title! == model.currentSong) {
                                Text(song.title!)
                                    .foregroundColor(.pink)
                                    .font(.headline)
                                    .lineLimit(2)
                            } else {
                                Text(song.title ?? "Unkown Song")
                                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                                    .font(.headline)
                                    .lineLimit(2)
                            }
                            Text("Unknown")
                                .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                                .font(.caption)
                        }
                    }
                    // plays the song if this card view is pressed
                    .onTapGesture {
                        model.playSong(id: song.id!, fromPlaylist: fromPlaylist, songTitle: song.title!)
                    }
                    
                    // menu which allows song to be manipulated or shared/exported
                    if(!fromPlaylist){
                        Spacer()
                        
                        Menu {
                            Button("Cancel", action: cancelMenu)
                            Button(action: { shareSong() }, label: { Text("Share Song") })
                            Button(action: { editSongTitle() }, label: { Text("Edit Song Title") })
                        } label: {
                            Label("", systemImage: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
    
    // Sets the song to be updated and updates the text to be shown to the user, then updates the alertShowing state to display the CustomAlert view
    func editSongTitle() {
        updateSong = song
        alertShowing.toggle()
        textEntered = String(song.title![..<song.title!.lastIndex(of: ".")!])
    }
    
    // Prompts user with the share file window, allowing them to share the song file associated with this song card view
    func shareSong() {
        let activityVC = UIActivityViewController(activityItems: [Helper.getDocumentsDirectory().appendingPathComponent(song.title!)], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    // do nothing if cancel is pressed in the menu
    func cancelMenu() {}
}
