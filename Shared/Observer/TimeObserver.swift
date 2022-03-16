//
//  TimeObserver.swift
//  Offline Music Player (iOS)
//
//  Created by Ben Wallace on 2022-03-16.
//


import AVKit
import Combine

class TimeObserver {
    let publisher = PassthroughSubject<TimeInterval, Never>()
    private weak var player: AVQueuePlayer?
    private var timeObservation: Any?
    private var paused = false
    
    init(player: AVQueuePlayer) {
        self.player = player
        
        // Periodically observe the player's current time, whilst playing
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            // If we've not been told to pause our updates
            guard !self.paused else { return }
            // Publish the new player time
            self.publisher.send(time.seconds)
        }
    }
    
    deinit {
        if let player = player,
            let observer = timeObservation {
            player.removeTimeObserver(observer)
        }
    }
    
    func pause(_ pause: Bool) {
        paused = pause
    }
}
