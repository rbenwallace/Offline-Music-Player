//
//  PlayerView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-26.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    private enum PlaybackState: Int {
        case waitingForSelection
        case buffering
        case playing
    }
    
    @EnvironmentObject var model: Model
    public var songId: UUID
    public var fromPlaylist: Bool
    public var songTitle: String
    
    @State private var currentTime: TimeInterval = 0
    @State private var currentDuration: TimeInterval = 0
    @State private var state = PlaybackState.waitingForSelection
    
    var body: some View {
        VStack {
            Slider(value: $currentTime,
                   in: 0...currentDuration,
                   onEditingChanged: sliderEditingChanged,
                   minimumValueLabel: Text("\(TimeFormat.formatSecondsToHMS(currentTime))"),
                   maximumValueLabel: Text("\(TimeFormat.formatSecondsToHMS(currentDuration))")) {
                    // I have no idea in what scenario this View is shown...
                    Text("seek/progress slider")
            }
            .disabled(state != .playing)
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .onTapGesture {
                        model.goBackward()
                 }
                
                Image(systemName: "backward.fill")
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .onTapGesture {
                        model.prev()
                        model.isPlaying = true
                 }
                
                Image(systemName: (model.isPlaying && model.audioPlayer.currentItem != nil) ? "pause.circle.fill": "play.circle.fill")
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .onTapGesture {
                        model.isPlaying.toggle()
                        if model.isPlaying{
                            model.playSong(id: songId, fromPlaylist: fromPlaylist, songTitle: songTitle)
                        } else {
                            model.pause()
                        }
                 }
                
                Image(systemName: "forward.fill")
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .onTapGesture {
                        model.next()
                        model.isPlaying = true
                 }
                
                Image(systemName: "goforward.15")
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .onTapGesture {
                        model.goForward()
                 }
                
                Menu {
                    Button(action: { }, label: { Text("Cancel") })
                    Button(action: { model.stopTimer() }, label: { Text("Stop Timer") })
                    Button(action: { model.sleepTimer(time: 3600) }, label: { Text("1 Hour") })
                    Button(action: { model.sleepTimer(time: 1800) }, label: { Text("30 Minutes") })
                    Button(action: { model.sleepTimer(time: 600) }, label: { Text("10 Minutes") })
                    Button(action: { model.sleepTimer(time: 60) }, label: { Text("1 Minute") })
                } label: {
                    model.sleepTimerOn ? Label("", systemImage: "moon.fill").tint(.white) : Label("", systemImage: "moon").tint(.white)
                }
            }
        }
        .onAppear(perform: loadData)
        .padding()
        // Listen out for the time observer publishing changes to the player's time
        .onReceive(model.timeObserver.publisher) { time in
            // Update the local var
            self.currentTime = time
            // And flag that we've started playback
            if time > 0 {
                self.state = .playing
            }
        }
        // Listen out for the duration observer publishing changes to the player's item duration
        .onReceive(model.durationObserver.publisher) { duration in
            // Update the local var
            self.currentDuration = duration
        }
        // Listen out for the item observer publishing a change to whether the player has an item
        .onReceive(model.itemObserver.publisher) { hasItem in
            self.state = hasItem ? .buffering : .waitingForSelection
            self.currentTime = 0
            self.currentDuration = 0
        }
    }
    
    private func loadData(){
        self.currentDuration = model.audioPlayer.currentItem?.duration.seconds ?? 0
    }
    
    // MARK: Private functions
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Tell the PlayerTimeObserver to stop publishing updates while the user is interacting
            // with the slider (otherwise it would keep jumping from where they've moved it to, back
            // to where the player is currently at)
            model.timeObserver.pause(true)
        }
        else {
            // Editing finished, start the seek
            state = .buffering
            let targetTime = CMTime(seconds: currentTime,
                                    preferredTimescale: 600)
            model.audioPlayer.seek(to: targetTime) { _ in
                // Now the (async) seek is completed, resume normal operation
                model.timeObserver.pause(false)
                self.state = .playing
            }
        }
    }
}
