//
//  PlaylistCardView.swift
//  Offline Music Player (iOS)
//
//  Created by Ben Wallace on 2022-03-17.
//

import SwiftUI

struct PlaylistCardView: View {
    private var playlist: Playlist
    
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
                    .lineLimit(1)
                    .font(.system(size: 22))
            }
        }
    }
}
