//
//  PlayerView.swift
//  Offline Music Player (iOS)
//
//  This view class represents the full screen player view that is displayed when a song is playing and the user clicks on the minimized bar view of the current playing song
//

import SwiftUI
import AVKit

struct PlayerView: View {
    // used to determine systems background color
    @Environment(\.colorScheme) var colorScheme
    
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // State TimeInterval variable which is updated by the view's receiver and populates the time slider's current time for the current playing song
    @State private var currentTime: TimeInterval = 0
    
    var body: some View {
        // only displays the view if there is a song currently playing
        if model.currentSong != nil{
            HStack {
                Spacer(minLength: 0)
                
                VStack {
                    // represents the image in the upper center of the view
                    Image(uiImage: UIImage(named: "song_cover") ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        .padding(.top, 40)
                    
                    // represents the song title and song artist of the current song playing
                    VStack {
                        Text(model.currentSong!)
                            .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                            .font(Font.system(.title2).bold())
                            .lineLimit(1)
                        Text("Unknown Artist")
                            .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                            .font(Font.system(.title3).bold())
                    }
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    
                    Spacer(minLength: 0)
                    
                    // represents the time bar slider for users to manipulate the current time of the current song playing
                    Slider(value: $currentTime,
                           in: 0...model.currentDuration,
                           onEditingChanged: timeSliderUpdated,
                           minimumValueLabel: Text("\(Helper.formattedTime(currentTime))"),
                           maximumValueLabel: Text("\(Helper.formattedTime(model.currentDuration))")) {
                    }
                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    Spacer(minLength: 0)
                    
                    HStack {
                        // represents the previous buttton
                        Image(systemName: "backward.fill")
                            .font(.system(size: 30))
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                model.previous()
                                model.isPlaying = true
                            }
                        
                        // represents the play/pause buttton
                        Image(systemName: (model.isPlaying && (model.getPlayerCurrentItem() != nil)) ? "pause.fill": "play.fill")
                            .font(.system(size: 40))
                            .padding()
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                if model.isPlaying{
                                    model.pause()
                                } else {
                                    model.unPause()
                                }
                         }
                        
                        // represents the next buttton
                        Image(systemName: "forward.fill")
                            .font(.system(size: 30))
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                model.next()
                                model.isPlaying = true
                            }
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                    
                    Spacer(minLength: 0)
                    
                    HStack {
                        // represents the buttton to exit the full screen view
                        Image(systemName: "arrow.backward.to.line")
                            .font(.system(size: 25))
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                withAnimation(Animation.spring(response: 0.7, dampingFraction: 0.85)) {
                                    model.isPlayerViewPresented = false
                                }
                            }
                        
                        Spacer(minLength: 0)
                        
                        // represents the -15 seconds buttton
                        Image(systemName: "gobackward.15")
                            .font(.system(size: 25))
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                model.goBackward()
                            }
                        
                        Spacer(minLength: 0)
                        
                        // represents the +15 seconds buttton
                        Image(systemName: "goforward.15")
                            .font(.system(size: 25))
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                model.goForward()
                            }
                        
                        Spacer(minLength: 0)
                        
                        // represents the sleep timer menu buttton
                        Menu {
                            Button(action: { }, label: { Text("Cancel") })
                            Button(action: { model.stopTimer() }, label: { Text("Stop Timer") })
                            Button(action: { model.sleepTimer(time: 3600) }, label: { Text("1 Hour") })
                            Button(action: { model.sleepTimer(time: 1800) }, label: { Text("30 Minutes") })
                            Button(action: { model.sleepTimer(time: 600) }, label: { Text("10 Minutes") })
                            Button(action: { model.sleepTimer(time: 60) }, label: { Text("1 Minute") })
                        } label: {
                            // displays the sleep timer as a filled or non filled moon depending whether a sleep timer has been set
                            model.sleepTimerOn ? Label("", systemImage: "moon.fill")
                                .tint(.white)
                                .font(.system(size: 25))
                                .padding(.horizontal, 15)
                                .multilineTextAlignment(.center)
                            : Label("", systemImage: "moon")
                                .tint(.white)
                                .font(.system(size: 25))
                                .padding(.horizontal, 15)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(Helper.getFontColour(colorScheme: colorScheme))
                    
                    Spacer(minLength: 0)
                }
                // Listen out for the time observer publishing changes to the player's time
                .onReceive(model.timeObserver.publisher) { time in
                    // Update the local var
                    currentTime = time
                }
                // Listen out for the item observer publishing a change to whether the player has an item
                .onReceive(model.currentSongObserver.publisher) { hasItem in
                    currentTime = 0
                    if hasItem {
                        if model.getPlayerCurrentItem()!.duration.isNumeric {
                            model.currentDuration =  TimeInterval(model.getPlayerCurrentItem()!.duration.seconds)
                        }
                    } else {
                        model.currentDuration =  0
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .onAppear(perform: loadData)
            .background(
                // gradient background of the view
                LinearGradient(gradient: Gradient(colors: [Color(.systemPink), Helper.primaryBackground]), startPoint: .top, endPoint: .bottom)
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    // actions that occur when the view is presented to the user
    private func loadData(){
        if model.getPlayerCurrentItem() != nil {
            // populates the time bar slider's duration with the duration of the current playing song
            if model.getPlayerCurrentItem()!.duration.isNumeric {
                model.currentDuration =  TimeInterval(model.getPlayerCurrentItem()!.duration.seconds)
            }
            
            // populates the time bar slider's current time with the current playback time of the current playing song
            if model.getPlayerCurrentItem()!.currentTime().isNumeric {
                currentTime =  TimeInterval(model.getPlayerCurrentItem()!.currentTime().seconds)
            }
        }
    }
    
    // Handles the time bar slider being manipulated 
    private func timeSliderUpdated(updateStarted: Bool) {
        // makes sure the time bar slider manipulation does not offset the view
//        if offset.height != .zero {
//            withAnimation {
//                offset = .zero
//            }
//        }
        
        if updateStarted {
            // Informs the timeObserver that the time slider is being updated and to temporarily stop sending time updates
            model.timeObserver.setTimeUpdating(timeUpdating: true)
        }
        else {
            // time bar slider update has been completed so audio player seeks to new current time and timeObserver returns to publishing time updates
            model.playerSeek(currentTime: currentTime)
        }
    }
}
