//
//  Playlist+CoreDataProperties.swift
//  Offline Music Player (iOS)
//
//  Manually managed Data Properties for Playlist entity
//
//

import Foundation
import CoreData


extension Playlist {

    // Fetch request for fetching Playlist entities
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    // the time the Playlist was created
    @NSManaged public var timestamp: Date?
    
    // the title of the Playlist
    @NSManaged public var title: String?
    
    // the songs associated with the playlist
    @NSManaged public var songs: NSSet?
    
    // an array of songs associated with the Playlist
    public var songArray: [Song] {
        let set = songs as? Set<Song> ?? []
        return set.sorted{
            $0.title! < $1.title!
        }
    }

}

// MARK: Generated accessors for songs
extension Playlist {

    // adds a song to the playlist's songs set
    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: Song)

    // removes a song from the playlist's songs set
    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: Song)

    // adds a set of songs to the playlist's songs set
    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)

    // removes a set of songs from the playlist's songs set
    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)

}

extension Playlist : Identifiable {

}
