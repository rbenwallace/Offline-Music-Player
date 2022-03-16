//
//  Playlist+CoreDataProperties.swift
//  Offline Music Player (iOS)
//
//  Created by Ben Wallace on 2022-03-16.
//
//

import Foundation
import CoreData


extension Playlist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?
    @NSManaged public var songs: NSSet?
    
    public var unwrappedTimestamp: Date {
        timestamp ?? Date()
    }
    
    public var unwrappedTitle: String {
        title ?? "Unknown"
    }
    
    public var songArray: [Song] {
        let set = songs as? Set<Song> ?? []
        return set.sorted{
            $0.unwrappedTitle < $1.unwrappedTitle
        }
    }

}

// MARK: Generated accessors for songs
extension Playlist {

    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: Song)

    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: Song)

    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)

    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)

}

extension Playlist : Identifiable {

}
