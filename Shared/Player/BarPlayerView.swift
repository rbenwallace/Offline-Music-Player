//
//  BarPlayerView.swift
//  Offline Music Player (iOS)
//
//  This view class represents the minimized player view that is displayed when a song is playing and the user is not in the full screen player view
//

import SwiftUI

struct BarPlayerView: View {
    // used to determine systems background color
    @Environment(\.colorScheme) var colorScheme
    
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    var body: some View {
        // only shows the view if a song is currently playing 
        if model.currentSong != nil {
            VStack {
                Spacer()
                
                HStack {
                    // displays audio image and title of currently playing song title
                    Image(uiImage: UIImage(named: "song_cover") ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding()
                    
                    // Displays the title of the current song along with its author
                    VStack(alignment: .leading) {
                        Text(model.currentSong ?? "")
                            .font(.headline)
                            .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                            .lineLimit(1)
                        Text("Unknown")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // handles play/pause button for the current playing song and is displayed on the far right of the view
                    HStack {
                        Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                            .font(.system(size: 30))
                            .padding()
                            .onTapGesture {
                                if model.isPlaying{
                                    model.pause()
                                } else {
                                    model.unPause()
                                }
                            }
                    }
                    .padding(.horizontal, 5)
                }
                // see through background that still provides visible text
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

