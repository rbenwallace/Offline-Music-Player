//
//  CurrentSongObserver.swift
//  Offline Music Player (iOS)
//
//  A class which acts as an observer of the audio players current playing song, which publishes updates when the current song changes and updates the current song's plays attribute
//
import SwiftUI
import Combine
import AVFoundation

class CurrentSongObserver {
    // publisher used to send Bool updates when the current song changes
    let publisher = PassthroughSubject<Bool, Never>()
    
    // Observer that monitors changes in the audio players .currentItem property
    private var currentSongObservation: NSKeyValueObservation?
    
    init(player: AVQueuePlayer) {
        // Observes the audio player's current song changing
        currentSongObservation = player.observe(\.currentItem) { [weak self] player, change in
            guard let self = self else { return }
            // Publishes whether or not the audio player is playing a song
            self.publisher.send(player.currentItem != nil)
            
            // When the audio player's current song changes, incriment the new songs plays attribute by 1
            if player.currentItem != nil {
                Model.shared.updatePlays()
            }
            // if for some reason the new current playing song is invalid or cant be played, skip to the next song
            else {
                // if a song does not play for some reason but there are more songs in the playlist, skip it
                if player.items().count > 0 {
                    player.advanceToNextItem()
                } else {
                    // there are no more songs so the player views should disappear
                    Model.shared.isPlaying = false
                    Model.shared.currentSong = nil
                    Model.shared.isPlayerViewPresented = false
                }
            }
        }
    }
    
    // destructor which invalidates the observer
    deinit {
        if let observer = currentSongObservation {
            observer.invalidate()
        }
    }
}
