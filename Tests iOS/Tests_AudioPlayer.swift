//
//  Tests_Library.swift
//  Tests iOS
//
//  Unit tests for the main functionalities of the audio player
//

@testable import Offline_Music_Player
import CoreData
import XCTest
import CoreMedia

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
        // tests that the audio player's current song is nil
        XCTAssertNil(self.model.getPlayerCurrentItem())
        
        // starts playing the audio player
        self.model.playQueue()
        
        // tests that audio player's current queue size is 8
        XCTAssertEqual(self.model.getAudioPlayerSize(), 8)
        
        // simulates the previous song button being pressed on the first song in the playlst
        self.model.prev()
        
        // tests that audio player's current queue size is still 8 after the user presses the previous song on the first song in the playlist while the playback time is 0 seconds
        XCTAssertEqual(self.model.getAudioPlayerSize(), 8)
        
        for _ in 0...6 {
            XCTAssertNotNil(self.model.getPlayerCurrentItem())
            self.model.next()
        }
        
        // tests that audio player's current queue size is 1 after navigating to the last song in its queue
        XCTAssertEqual(self.model.getAudioPlayerSize(), 1)
        
        // tests that audio player's current queue size is 2 after the previous button is clicked while the audioPlayer has a size of 1 and has a current playback time of 0 seconds
        self.model.prev()
        XCTAssertEqual(self.model.getAudioPlayerSize(), 2)
        
        // brings the audio player's current item back to the last item in the playlist, causing the audio player;'s queue to be of size 1
        self.model.next()
        XCTAssertEqual(self.model.getAudioPlayerSize(), 1)
        
        // tests that audio player's current queue size is 1 and the playback time is 0 seconds after the previous button is clicked while the audioPlayer has a size of 1 and has a current playback time of more than 5 seconds
        self.model.testSeek(currentTime: 30)
        self.model.prev()
        XCTAssertEqual(self.model.getPlayerCurrentItem()?.currentTime().seconds, 0)
        XCTAssertEqual(self.model.getAudioPlayerSize(), 1)
        
        for x in (1...7).reversed() {
            // tests that audio player's current queue size is correct after the each previous button click until the user is back to the first song in the current playlist
            XCTAssertEqual(self.model.getAudioPlayerSize(), 8-x)
            self.model.prev()
        }
    }
    
    // tests that the model's audio player's play and pause button functionality
    func testAudioPlayerPlayPauseButton() throws {
        // tests that audio player starts off in the not playing state
        XCTAssertFalse(self.model.isPlaying)
        
        // starts the audio player
        self.model.playQueue()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(self.model.isPlaying)
        
        // pauses the audio player
        self.model.pause()
        
        // tests that audio player is in the not playing state
        XCTAssertFalse(self.model.isPlaying)
        
        // resumes the audio player
        self.model.unPause()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(self.model.isPlaying)
    }
    
    // tests that the model's audio player's +/- 15 seconds button functionalies
    func testAudioPlayerPlusMinus15Buttons() throws {
        // starts the audio player
        self.model.playQueue()
        
        // pauses the audio player and sets its playback time to 20 seconds
        self.model.pause()
        self.model.testSeek(currentTime: 20)
        
        // simulates a -15 seconds button press
        self.model.goBackward()
        
        // asserts that the audio player's current playback time is 5 seconds
        XCTAssertEqual(self.model.getPlayerCurrentItem()?.currentTime(), CMTime(seconds: 5, preferredTimescale: 600))
        
        // simulates a -15 seconds button press
        self.model.goBackward()
        
        // asserts that the audio player's current playback time is 0 seconds and not -10 seconds
        XCTAssertEqual(self.model.getPlayerCurrentItem()?.currentTime(), CMTime(seconds: 0, preferredTimescale: 600))
        
        // simulates a +15 seconds button press
        self.model.goForward()
        
        // asserts that the audio player's current playback time is 15
        XCTAssertEqual(self.model.getPlayerCurrentItem()?.currentTime(), CMTime(seconds: 15, preferredTimescale: 600))
    }
    
    // tests that the model's audio player's sleep timer button functionality
    func testAudioPlayerSleepTimerButton() throws {
        // starts the audio player
        self.model.playQueue()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(self.model.isPlaying)
        
        // sets a sleep timer for 2 seconds
        self.model.sleepTimer(time: 2)
        
        // tests that audio player's sleep timer is on
        XCTAssertTrue(self.model.sleepTimerOn)
        
        // waits for 5 seconds to pass
        do {
            sleep(5)
        }
        
        // resumes the audio player
        self.model.unPause()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(self.model.isPlaying)
        
        // sets a sleep timer for 3 seconds
        self.model.sleepTimer(time: 3)
        
        // tests that audio player's sleep timer is on
        XCTAssertTrue(self.model.sleepTimerOn)
        
        // stops the audio player's sleep timer
        self.model.stopTimer()
        
        // tests that audio player's sleep timer is off
        XCTAssertFalse(self.model.sleepTimerOn)
        
        // waits for 5 seconds to pass
        do {
            sleep(5)
        }
        
        // tests that audio player is in the playing state after the stopped sleep timer would have completed
        XCTAssertTrue(self.model.isPlaying)
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
