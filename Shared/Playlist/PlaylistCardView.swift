//
//  PlaylistCardView.swift
//  Offline Music Player (iOS)
//
//  This view class represents the card view for each playlist inside PlaylistView.swift
//

import SwiftUI

struct PlaylistCardView: View {
    // used to determine systems background color
    @Environment(\.colorScheme) var colorScheme
    
    // playlist entity which this card view represents
    private var playlist: Playlist
    
    // constructor to initialize playlist which this card view represents
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    var body: some View {
        HStack {
            // Card view which displays a preset image and the playlist name
            HStack {
                Image(uiImage: UIImage(named: "playlist_cover") ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 10)
                Text(self.playlist.title!)
                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                    .lineLimit(1)
                    .font(.system(size: 22))
            }
        }
    }
}
