//
//  Tests_Library.swift
//  Tests iOS
//
//  Created by Ben Wallace on 2022-04-02.
//

@testable import Offline_Music_Player
import CoreData
import XCTest

class Tests_Library: XCTestCase {
    var persistenceController: PersistenceController!
    var model: Model!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController.unitTest
        model = Model()
    }
    
    override func tearDown() {
        persistenceController = nil
        model = nil
        super.tearDown()
    }
    
    // used to add song to apps document directory during tests
    private func addToDocumentDirectory(title: String) {
        guard let data = NSDataAsset(name: "test_song.mp3")?.data else { return }
        do {
            try data.write(to: Helper.getDocumentsDirectory().appendingPathComponent(title))
        } catch {
            // song could not be written to app's document directory
        }
    }
    
    func testSongsSaveToCoreData() throws {
        print("gets here 1")
        let viewContext = persistenceController.container.viewContext
        print("gets here 2")
        let song1 = Song(context: viewContext)
        song1.id = UUID()
        song1.timestamp = Date()
        song1.plays = 0
        song1.title = "song1"
        
        let song2 = Song(context: viewContext)
        song2.id = UUID()
        song2.timestamp = Date()
        song2.plays = 0
        song2.title = "song2"
        
        let song3 = Song(context: viewContext)
        song3.id = UUID()
        song3.timestamp = Date()
        song3.plays = 0
        song3.title = "song3"
        
        try viewContext.save()
        
        let request = NSFetchRequest<Song>(entityName: "Song")
        let result = try viewContext.fetch(request) as [Song]
        XCTAssertEqual(result.count, 3)
    }
}
