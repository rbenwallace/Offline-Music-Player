//
//  Song+CoreDataProperties.swift
//  Offline Music Player (iOS)
//
//  Created by Ben Wallace on 2022-03-16.
//
//

import Foundation
import CoreData


extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var plays: Int32
    @NSManaged public var title: String?
    @NSManaged public var id: UUID?
    @NSManaged public var playlists: NSSet?
    
    public var unwrappedTimestamp: Date {
        timestamp ?? Date()
    }
    
    public var unwrappedTitle: String {
        title ?? "Unknown"
    }
    
    public var playlistArray: [Playlist] {
        let set = playlists as? Set<Playlist> ?? []
        return set.sorted{
            $0.unwrappedTitle < $1.unwrappedTitle
        }
    }

}

// MARK: Generated accessors for playlists
extension Song {

    @objc(addPlaylistsObject:)
    @NSManaged public func addToPlaylists(_ value: Playlist)

    @objc(removePlaylistsObject:)
    @NSManaged public func removeFromPlaylists(_ value: Playlist)

    @objc(addPlaylists:)
    @NSManaged public func addToPlaylists(_ values: NSSet)

    @objc(removePlaylists:)
    @NSManaged public func removeFromPlaylists(_ values: NSSet)

}

extension Song : Identifiable {

}
