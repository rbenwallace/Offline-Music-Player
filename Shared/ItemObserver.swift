//
//  ItemObserver.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-03-08.
//
import SwiftUI
import CoreData
import Combine
import AVFoundation

class ItemObserver {
    @EnvironmentObject var model: Model
    let publisher = PassthroughSubject<Bool, Never>()
    private var itemObservation: NSKeyValueObservation?
    
    init(player: AVQueuePlayer) {
        // Observe the current item changing
        itemObservation = player.observe(\.currentItem) { [weak self] player, change in
            guard let self = self else { return }
            // Publish whether the player has an item or not
            self.publisher.send(player.currentItem != nil)
            if player.currentItem != nil {
                let asset = player.currentItem!.asset
                if let urlAsset = asset as? AVURLAsset {
                    do {
                        let viewContext = PersistenceController.shared.container.viewContext
                        let request = NSFetchRequest<Song>(entityName: "Song")
                        request.predicate = NSPredicate(format: "title == %@", urlAsset.url.lastPathComponent)
                        let result = try viewContext.fetch(request) as [Song]
                        if result.count != 0 {
                            let song = result.first!
                            song.plays = song.plays + 1
                            print("Song: ", song.title!, "has this many plays: ", song.plays)
                            try viewContext.save()
                        }
                    } catch let error as NSError {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            } else {
                if player.items().count > 0 {
                    player.advanceToNextItem()
                }
            }
        }
    }
    
    deinit {
        if let observer = itemObservation {
            observer.invalidate()
        }
    }
}
