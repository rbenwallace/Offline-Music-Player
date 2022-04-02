//
//  CurrentSongObserver.swift
//  Offline Music Player (iOS)
//
//  A class which acts as an observer of the audio players current playing song, which publishes updates when the current song changes and updates the current song's plays attribute
//
import SwiftUI
import CoreData
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
                // parse song details from audio player's current playing song
                let asset = player.currentItem!.asset
                if let urlAsset = asset as? AVURLAsset {
                    // fetch new current playing song from the database and update its plays attribute then save the viewContext
                    do {
                        let viewContext = PersistenceController.shared.container.viewContext
                        let request = NSFetchRequest<Song>(entityName: "Song")
                        request.predicate = NSPredicate(format: "title == %@", urlAsset.url.lastPathComponent)
                        let result = try viewContext.fetch(request) as [Song]
                        if result.count != 0 {
                            let song = result.first!
                            song.plays = song.plays + 1
                            try viewContext.save()
                        }
                    } catch {
                        print("Failed to incriment current song's plays attribute in song observer: \(error.localizedDescription)")
                    }
                }
            }
            // if for some reason the new current playing song is invalid or cant be played, skip to the next song
            else {
                if player.items().count > 0 {
                    player.advanceToNextItem()
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
