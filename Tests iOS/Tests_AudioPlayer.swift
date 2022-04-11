//
//  Tests_Library.swift
//  Tests iOS
//
//  Unit tests for the main functionalities of the audio player
//

@testable import Offline_Music_Player
import CoreData
import XCTest

class Tests_AudioPlayer: XCTestCase {
    // model class which contains the audio player to be tested and the audio player's helper functions
    var model: Model!
    
    // code which is run before each test to set up a unit test
    override func setUp() {
        super.setUp()
        model = Model()
        populateTestAudioPlayer()
        addToDocumentDirectory(title: "test_song.mp3")
    }
    
    // code which is run after each test
    override func tearDown() {
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
    
    // loads 8 songs into audio player for testing
    private func populateTestAudioPlayer() {
        for _ in 0...7 {
            // populates model's playlistSongs array
            self.model.playlistSongs.append("test_song.mp3")
            
            // populates model's playerSongs array
            self.model.appendPlayerItem(title: "test_song.mp3")
        }
    }
    
    // tests that the model's audio player plays when the playQueue function is called
    func testAudioPlayerPlays() throws {
        // tests that audio player starts in a not playing state
        XCTAssertFalse(self.model.isPlaying)
        
        // starts the audio player
        self.model.playQueue()
        
        // tests that audio player is now playing
        XCTAssertTrue(self.model.isPlaying)
    }
    
    // tests that the model's audio player's next button functionality
    func testAudioPlayerNextButton() throws {
        // tests that the audio player's current playing song is nil before it has started
        XCTAssertNil(self.model.getPlayerCurrentItem())
        
        // starts playing the audio player
        self.model.playQueue()
        
        // runs for each item in the audio player
        for _ in 0...7 {
            // tests that the current playing item is not nil, then calls the audio player's next*() function
            XCTAssertNotNil(self.model.getPlayerCurrentItem())
            self.model.next()
        }
        
        // tests that the audio player's current item is nil once it has called next() 8 times
        XCTAssertNil(self.model.getPlayerCurrentItem())
    }
    
    // tests that the model's audio player's previous button functionality
    func testAudioPlayerPreviousButton() throws {
        XCTAssertNil(self.model.getPlayerCurrentItem())
        self.model.playQueue()
        for _ in 0...7 {
            XCTAssertNotNil(self.model.getPlayerCurrentItem())
            self.model.next()
        }
        XCTAssertNil(self.model.getPlayerCurrentItem())
    }
    
    // tests that the model's audio player's play and pause button functionality
    func testAudioPlayerPlayPauseButton() throws {
        
    }
    
    // tests that the model's audio player's +/- 15 seconds button functionalies
    func testAudioPlayerPlusMinus15Buttons() throws {
        
    }
    
    // tests that the model's audio player's sleep timer button functionality
    func testAudioPlayerSleepTimerButton() throws {
        sleep(10)
    }
    
//    func testAudioPlayerIDK() throws {
//        let persistenceController = PersistenceController.shared
//        let viewContext = persistenceController.container.viewContext
//        let song = Song(context: viewContext)
//        song.id = UUID()
//        song.title = "test_song.mp3"
//        song.timestamp = Date()
//        song.plays = 0
//        try viewContext.save()
//    }
}
