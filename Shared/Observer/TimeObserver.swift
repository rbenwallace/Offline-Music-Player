//
//  TimeObserver.swift
//  Offline Music Player (iOS)
//
//  A class which acts as an observer of the audio players current playing song's playback time, which publishes updates constantly when the current song is playing, which is received by the PlayerView in order to populate its time bar slider
//


import AVKit
import Combine

class TimeObserver {
    // publisher for publishing TimeInterval updates to the audio player's current time
    let publisher = PassthroughSubject<TimeInterval, Never>()
    
    // audio player whos current playback time is to be observed
    private weak var player: AVQueuePlayer?
    
    // observer varaible to observe changes in the audio player's current song's playback time
    private var timeObservation: Any?
    
    // keeps track of whether the player is paused or not
    private var paused = false
    
    // constructor to store audio player reference and initialize time observer
    init(player: AVQueuePlayer) {
        self.player = player
        
        // Sets observer to observe the audio player's current song's playback time every 0.5 seconds
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            // ensures self exists
            guard let self = self else {
                return
            }
            
            // returns if audio player is paused
            if self.paused {
                return
            }
            
            // Publishes the new current playback time of the audio player to be received by PlayerView's time Slider
            self.publisher.send(time.seconds)
        }
    }
    
    // destructor which removes the time observer from the audio player
    deinit {
        if self.player != nil && self.timeObservation != nil {
            self.player!.removeTimeObserver(self.timeObservation!)
        }
    }
    
    // updates the observers paused state when the audio player has paused
    func pause(_ pause: Bool) {
        self.paused = pause
    }
}
