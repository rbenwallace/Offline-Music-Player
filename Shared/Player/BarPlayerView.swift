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
    
    // keeps track of the amount the text has been dragged left and right
    @State private var xOffset = CGSize.zero
    
    @Binding private var barYOffset: CGSize
    
    @Binding private var barYDragging: Bool
    
    @State private var xDragging = false
    
    @State private var dragStarted = false
            
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    init(barYOffset: Binding<CGSize>, barYDragging: Binding<Bool>) {
        self._barYOffset = barYOffset
        self._barYDragging = barYDragging
    }
    
    var body: some View {
        // only shows the view if a song is currently playing 
        if model.currentSong != nil {
            VStack {
                Spacer()
                
                HStack {
                    ZStack(alignment: .leading) {
                        // Displays the title of the current song along with its author
                        HStack {
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
                        }
                        .contentShape(Rectangle())
                        .offset(x: xOffset.width, y: 0)
                        // makes the view fade as it gets dragged closer to the bottom
                        .opacity(4 - Double(abs(xOffset.width)/25))
                        .padding(.leading, 100)
                        // handles downward drag gesture to exit the view
                        
                        // displays audio image and title of currently playing song title
                        Image(uiImage: UIImage(named: "song_cover") ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .padding()
                    }
                    
                    // handles play/pause button for the current playing song and is displayed on the far right of the view
                    HStack {
                        Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
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
                
                .onTapGesture {
                    withAnimation(Animation.spring(response: 0.7, dampingFraction: 0.85)) {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
                        model.isPlayerViewPresented.toggle()
                    }
                }
            }
            .offset(x: 0, y: barYOffset.height-49)
            .opacity(2 - Double(abs(barYOffset.height)/100))
            .gesture(
                DragGesture()
                    // If the view is being dragged down, update the offset value
                    .onChanged { gesture in
                        dragStarted = true
                        if abs(gesture.translation.width) > abs(gesture.translation.height) {
                            xOffset = gesture.translation
                            xDragging = true
                        }
                        else {
                            barYDragging = true
                            barYOffset = gesture.translation
                            xDragging = false
                        }
                    }
                    // When the drag gesture has been completed, update the isPlayerViewPresented variable if the view was dragged down far enough or otherwise reset the offset to 0
                    .onEnded { _ in
                        if xDragging {
                            if xOffset.width > 80 {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
                                model.previous()
                            }
                            else if xOffset.width < -100 {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
                                model.next()
                            }
                            withAnimation {
                                xOffset = .zero
                            }
                            barYOffset = .zero
                        }
                        else {
                            if barYOffset.height < -200 {
                                withAnimation {
                                    model.isPlayerViewPresented = true
                                }
                                barYOffset = .zero
                            }
                            else {
                                withAnimation {
                                    barYOffset = .zero
                                }
                            }
                            barYDragging = false
                            xOffset = .zero
                        }
                        dragStarted = true
                    }
            )
        }
    }
}

