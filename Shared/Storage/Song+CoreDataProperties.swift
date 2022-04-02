//
//  Song+CoreDataProperties.swift
//  Offline Music Player (iOS)
//
//  Manually managed Data Properties for Song entity
//
//

import Foundation
import CoreData


extension Song {

    // Fetch request for Song entity
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    // NSManaged attributes of Song entity
        
    // the time the Song was created
    @NSManaged public var id: UUID?
    
    // the number of times the Song has been played
    @NSManaged public var plays: Int32
    
    // the title of the Song
    @NSManaged public var timestamp: Date?
    
    // the unique id of the song
    @NSManaged public var title: String?
    
    // the playlists associated with the Song
    @NSManaged public var playlists: NSSet?

    // array of playlists associated with the Song
    public var playlistArray: [Playlist] {
        let set = playlists as? Set<Playlist> ?? []
        return set.sorted{
            $0.title! < $1.title!
        }
    }
}

// MARK: Generated accessors for playlists
extension Song {

    // adds a playlist to the song's playlists set
    @objc(addPlaylistsObject:)
    @NSManaged public func addToPlaylists(_ value: Playlist)

    // removes a playlist from the song's playlists set
    @objc(removePlaylistsObject:)
    @NSManaged public func removeFromPlaylists(_ value: Playlist)

    // adds a set of playlists to the song's playlists set
    @objc(addPlaylists:)
    @NSManaged public func addToPlaylists(_ values: NSSet)

    // removes a set of playlists from the song's playlists set
    @objc(removePlaylists:)
    @NSManaged public func removeFromPlaylists(_ values: NSSet)

}

extension Song : Identifiable {

}
