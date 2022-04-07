//
//  PlayerView.swift
//  Offline Music Player (iOS)
//
//  This view class represents the full screen player view that is displayed when a song is playing and the user clicks on the minimized bar view of the current playing song
//

import SwiftUI
import AVKit

struct PlayerView: View {
    // environment object which contains published variables used in this view, and allows for audio player manipulation
    @EnvironmentObject var model: Model
    
    // State TimeInterval variable which is updated by the view's receiver and populates the time slider's current time for the current playing song
    @State private var currentTime: TimeInterval = 0
    
    // State TimeInterval variable which is updated by the view's receiver and populates the time slider's duration time for the current playing song
    @State private var currentDuration: TimeInterval = 0
    
    var body: some View {
        // only displays the view if there is a song currently playing
        if self.model.currentSong != nil{
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
                        Text(self.model.currentSong!)
                            .foregroundColor(.white)
                            .font(Font.system(.title2).bold())
                            .lineLimit(1)
                        Text("Unknown Artist")
                            .foregroundColor(.gray)
                            .font(Font.system(.title3).bold())
                    }
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    
                    Spacer(minLength: 0)
                    
                    // represents the time bar slider for users to manipulate the current time of the current song playing
                    Slider(value: self.$currentTime,
                           in: 0...self.currentDuration,
                           onEditingChanged: timeSliderUpdated,
                           minimumValueLabel: Text("\(Helper.formattedTime(self.currentTime))"),
                           maximumValueLabel: Text("\(Helper.formattedTime(self.currentDuration))")) {
                    }
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
                                self.model.prev()
                                self.model.isPlaying = true
                            }
                        
                        // represents the play/pause buttton
                        Image(systemName: (model.isPlaying && (model.audioPlayer.currentItem != nil)) ? "pause.fill": "play.fill")
                            .font(.system(size: 40))
                            .padding()
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                if self.model.isPlaying{
                                    self.model.pause()
                                } else {
                                    self.model.unPause()
                                }
                         }
                        
                        // represents the next buttton
                        Image(systemName: "forward.fill")
                            .font(.system(size: 30))
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                self.model.next()
                                self.model.isPlaying = true
                            }
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(.white)
                    
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
                                self.model.goBackward()
                            }
                        
                        Spacer(minLength: 0)
                        
                        // represents the +15 seconds buttton
                        Image(systemName: "goforward.15")
                            .font(.system(size: 25))
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                self.model.goForward()
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
                    .foregroundColor(.white)
                    
                    Spacer(minLength: 0)
                }
                // Listen out for the time observer publishing changes to the player's time
                .onReceive(model.timeObserver.publisher) { time in
                    // Update the local var
                    self.currentTime = time
                }
                // Listen out for the item observer publishing a change to whether the player has an item
                .onReceive(model.currentSongObserver.publisher) { hasItem in
                    self.currentTime = 0
                    if hasItem && self.model.audioPlayer.currentItem != nil {
                        if self.model.audioPlayer.currentItem!.duration.isNumeric {
                            self.currentDuration =  TimeInterval(self.model.audioPlayer.currentItem!.duration.seconds)
                        }
                    } else {
                        self.currentDuration =  0
                    }
                }
                Spacer(minLength: 0)
            }
            .onAppear(perform: loadData)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.systemPink), .black]), startPoint: .top, endPoint: .bottom)
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    // actions that occur when the view is presented to the user
    private func loadData(){
        if self.model.audioPlayer.currentItem != nil {
            // populates the time bar slider's duration with the duration of the current playing song
            if self.model.audioPlayer.currentItem!.duration.isNumeric {
                self.currentDuration =  TimeInterval(self.model.audioPlayer.currentItem!.duration.seconds)
            }
            
            // populates the time bar slider's current time with the current playback time of the current playing song
            if self.model.audioPlayer.currentItem!.currentTime().isNumeric {
                self.currentTime =  TimeInterval(self.model.audioPlayer.currentItem!.currentTime().seconds)
            }
        }
    }
    
    private func timeSliderUpdated(updateStarted: Bool) {
        if updateStarted {
            // Informs the timeObserver that the time slider is being updated and to temporarily stop sending time updates
            self.model.timeObserver.setTimeUpdating(timeUpdating: true)
        }
        else {
            // The time slider update is complete and the audio player must now seek to the new current time
            self.model.audioPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600)) { _ in
                // Informs the timeObserver that the time slider is done updating and to continue sending time updates
                self.model.timeObserver.setTimeUpdating(timeUpdating: false)
            }
        }
    }
}
