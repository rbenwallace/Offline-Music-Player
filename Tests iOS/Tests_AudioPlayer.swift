//
//  Tests_AudioPlayer.swift
//  Tests iOS
//
//  Unit tests for the core functionalities of the app's audio player
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
    }
    
    // code which is run after each test
    override func tearDown() {
        model = nil
        super.tearDown()
    }
    
    // loads 8 songs into audio player for testing
    private func populateTestAudioPlayer() {
        for _ in 0...7 {
            // populates model's playlistSongs array
            model.playlistSongs.append("test_song.mp3")
            
            // populates model's playerSongs array
            model.appendPlayerItem(title: "test_song.mp3")
        }
    }
    
    // tests that the model's audio player can access app's document directoy files
    func testAudioPlayerAccessesDocumentDirectory() throws {
        //writes test song mp3 to app's document directory
        guard let data = NSDataAsset(name: "test_song.mp3")?.data else { return }
        try data.write(to: Helper.getDocumentsDirectory().appendingPathComponent("test_song.mp3"))
        
        // tests that the test mp3 file was stored properly in the app's document directory and is accessible for later use
        XCTAssertTrue(FileManager.default.fileExists(atPath: Helper.getDocumentsDirectory().appendingPathComponent("test_song.mp3").path))
    }
    
    // tests that the model's audio player plays when the playQueue function is called
    func testAudioPlayerPlays() throws {
        // tests that audio player starts in a not playing state
        XCTAssertFalse(model.isPlaying)
        
        // starts the audio player
        model.playQueue()
        
        // tests that audio player is now playing
        XCTAssertTrue(model.isPlaying)
    }
    
    // tests that the model's audio player's next button being pressed when the first song in the current playlist is playing
    func testAudioPlayerInitialNextButtonPress() throws {
        // tests that the audio player's current playing song is nil before it has started
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // tests that the audio player's queue size starts at 8
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
        
        // simulates the user pressing the next button
        model.next()
        
        // tests that the current song is not nil
        XCTAssertNotNil(model.getPlayerCurrentItem())
        
        // tests that the audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
        
        // tests that the audio player's queue size has shrunk by one
        XCTAssertEqual(model.getAudioPlayerSize(), 7)
    }
    
    // tests that the model's audio player's next button being pressed when a song somewhere in the middle of the current playlist is playing
    func testAudioPlayerGeneralNextButtonPress() throws {
        // tests that the audio player's current playing song is nil before it has started
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // simulates the user pressing the next button
        model.next()
        
        // tests that the current song is not nil
        XCTAssertNotNil(model.getPlayerCurrentItem())
        
        // tests that the audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
        
        // tests that the audio player's queue size has shrunk by one
        XCTAssertEqual(model.getAudioPlayerSize(), 7)
        
        // simulates the user pressing the next button
        model.next()
        
        // tests that the current song is not nil
        XCTAssertNotNil(model.getPlayerCurrentItem())
        
        // tests that the audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
        
        // tests that the audio player's queue size has shrunk by one
        XCTAssertEqual(model.getAudioPlayerSize(), 6)
    }
    
    // tests that the model's audio player's next button being pressed when the last song in the current playlist is playing
    func testAudioPlayerLastNextButtonPress() throws {
        // tests that the audio player's current playing song is nil before it has started
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // simulates the next button being pressed 7 times to get to the last song in the audio player's queue
        for x in (1...7).reversed() {
            // simulates the next button being pressed
            model.next()
            
            // tests that the current playing item is not nil, then calls the audio player's next*() function
            XCTAssertNotNil(model.getPlayerCurrentItem())
            
            // tests that the audio player is in the playing state
            XCTAssertTrue(model.isPlaying)
            
            // tests that the audio player's queue size has shrunk by one
            XCTAssertEqual(model.getAudioPlayerSize(), x)
        }
        
        // tests that the audio player's queue size is now only 1
        XCTAssertEqual(model.getAudioPlayerSize(), 1)
        
        // simulates the next button being pressed when the last song in the current playlist is being played
        model.next()
        
        // tests that the audio player's current item is nil once the simulated next button press has occured while the audio player only has one song in its queue
        XCTAssertNil(model.getPlayerCurrentItem())
    }
    
    // tests that the model's audio player's previous button functionality when the current song is the first song in the current playlist
    func testAudioPlayerPreviousButtonFirstPlaylistSong() throws {
        // tests that the audio player's current song is nil
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // tests that audio player's current queue size is 8
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
        
        // simulates the previous song button being pressed on the first song in the playlst
        model.prev()
        
        // tests that audio player's current queue size is still 8 after the user presses the previous song on the first song in the playlist while the playback time is 0 seconds
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
    }
    
    // tests that the model's audio player's previous button functionality when the audio player's current playback time is less than 5 seconds
    func testAudioPlayerPreviousButtonBefore5Seconds() throws {
        // tests that the audio player's current song is nil
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // tests that audio player's current queue size is 8
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
        
        // brings the audio player to the second song in the current playlist
        model.next()
        XCTAssertEqual(model.getAudioPlayerSize(), 7)
        
        // tests that the audio player's current playback time is less than 5 seconds, and specifically 0 seconds
        XCTAssertEqual(model.getPlayerCurrentItem()?.currentTime().seconds, 0)
        
        // simulates the previous button being pressed when the audio player's current playback time is less than 5 seconds and tests that the audio player's queue size is one greater now
        model.prev()
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
    }
    
    // tests that the model's audio player's previous button functionality when the audio player's current playback time is more than 5 seconds
    func testAudioPlayerPreviousButtonAfter5Seconds() throws {
        // tests that the audio player's current song is nil
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // tests that audio player's current queue size is 8
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
        
        // brings the audio player to the second song in the current playlist
        model.next()
        XCTAssertEqual(model.getAudioPlayerSize(), 7)
        
        // sets the audio players current playback time to 30 seconds and tests that the playback time is 30
        model.testSeek(currentTime: 30)
        XCTAssertEqual(model.getPlayerCurrentItem()?.currentTime().seconds, 30)
        
        // tests that audio player's current queue size is 7 and the playback time is 0 seconds after the previous button is clicked while the audioPlayer has a size of 7 and has a current playback time of more than 5 seconds
        model.prev()
        XCTAssertEqual(model.getPlayerCurrentItem()?.currentTime().seconds, 0)
        XCTAssertEqual(model.getAudioPlayerSize(), 7)
    }
    
    // tests that the model's audio player's previous button functionality being pressed when the audio player's curremt song is at the last song in the current playlist until the current song is the first song in the current playlist
    func testAudioPlayerPreviousButtonLastSongtoFirstSong() throws {
        // tests that the audio player's current song is nil
        XCTAssertNil(model.getPlayerCurrentItem())
        
        // starts playing the audio player
        model.playQueue()
        
        // tests that audio player's current queue size is 8
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
        
        // navigate audio player to its last song in its queue
        for _ in 0...6 {
            model.next()
        }
        
        // tests that audio player's current queue size is 1 after navigating to the last song in its queue
        XCTAssertEqual(model.getAudioPlayerSize(), 1)
        
        for x in (1...7).reversed() {
            // tests that audio player's current queue size is correct after the each previous button click until the user is back to the first song in the current playlist
            XCTAssertEqual(model.getAudioPlayerSize(), 8-x)
            model.prev()
        }
        
        // tests that audio player's current queue size is 8 after navigating to the first song in the current playlist by using simulated button presses
        XCTAssertEqual(model.getAudioPlayerSize(), 8)
    }
    
    // tests that the model's audio player's play and pause button functionality
    func testAudioPlayerPlayPauseButton() throws {
        // tests that audio player starts off in the not playing state
        XCTAssertFalse(model.isPlaying)
        
        // starts the audio player
        model.playQueue()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
        
        // pauses the audio player
        model.pause()
        
        // tests that audio player is in the not playing state
        XCTAssertFalse(model.isPlaying)
        
        // resumes the audio player
        model.unPause()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
    }
    
    // tests that the model's audio player's - 15 seconds button functionaly
    func testAudioPlayerMinus15Button() throws {
        // starts the audio player
        model.playQueue()
        
        // pauses the audio player and sets its playback time to 20 seconds
        model.pause()
        model.testSeek(currentTime: 20)
        
        // simulates a -15 seconds button press
        model.goBackward()
        
        // asserts that the audio player's current playback time is 5 seconds
        XCTAssertEqual(model.getPlayerCurrentItem()?.currentTime(), CMTime(seconds: 5, preferredTimescale: 600))
        
        // simulates a -15 seconds button press
        model.goBackward()
        
        // asserts that the audio player's current playback time is 0 seconds and not -10 seconds
        XCTAssertEqual(model.getPlayerCurrentItem()?.currentTime(), CMTime(seconds: 0, preferredTimescale: 600))
    }
    
    // tests that the model's audio player's + 15 seconds button functionaly
    func testAudioPlayerPlus15Button() throws {
        // starts the audio player
        model.playQueue()
        
        // pauses the audio player and sets its playback time to 20 seconds
        model.pause()
        
        // simulates a +15 seconds button press
        model.goForward()
        
        // asserts that the audio player's current playback time is 15
        XCTAssertEqual(model.getPlayerCurrentItem()?.currentTime(), CMTime(seconds: 15, preferredTimescale: 600))
    }
    
    // tests that the model's audio player's sleep timer button functionality
    func testAudioPlayerSleepTimerButton() throws {
        // starts the audio player
        model.playQueue()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
        
        // sets a sleep timer for 2 seconds
        model.sleepTimer(time: 2)
        
        // tests that audio player's sleep timer is on
        XCTAssertTrue(model.sleepTimerOn)
        
        // waits for 5 seconds to pass
        do {
            sleep(5)
        }
        
        // resumes the audio player
        model.unPause()
        
        // tests that audio player is in the playing state
        XCTAssertTrue(model.isPlaying)
        
        // sets a sleep timer for 3 seconds
        model.sleepTimer(time: 3)
        
        // tests that audio player's sleep timer is on
        XCTAssertTrue(model.sleepTimerOn)
        
        // stops the audio player's sleep timer
        model.stopTimer()
        
        // tests that audio player's sleep timer is off
        XCTAssertFalse(model.sleepTimerOn)
        
        // waits for 5 seconds to pass
        do {
            sleep(5)
        }
        
        // tests that audio player is in the playing state after the stopped sleep timer would have completed
        XCTAssertTrue(model.isPlaying)
    }
}
