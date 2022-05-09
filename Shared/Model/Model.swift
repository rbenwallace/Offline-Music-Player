//
//  Model.swift
//  Offline Music Player (iOS)
//
//  This class is used as an environment object which is passed throughout views within the app and allows the views to use it to manipulate the audio player
//

import Foundation
import AVKit
import CoreData

class Model: ObservableObject {
    // shared instance of model
    static let shared = Model()

    // Audio player
    private var audioPlayer: AVPlayer
    
    // Published array of songs used to display playlist songs in PlaylistSongsView
    @Published var songs = [Song]()
    
    // Published array of songs used to display queued songs in QueueView
    @Published var queuedSongs = [Song]()
    
    // Published boolean for keeping track of whether or not audioPlayer is playing or not
    @Published var isPlaying = false
        
    // Published String that keeps track of the current Song that is playing
    @Published var currentSong: String?
    
    // Published boolean which keeps track of whether or not the sleep timer is currently on
    @Published var sleepTimerOn = false
    
    // Published Timer to keep track of the current time left in the sleep timer, if it is on
    @Published var timer: Timer?
    
    // Published Observer for keeping track of the audio player's current song's current playback time
    @Published var timeObserver: TimeObserver
        
    // Published Observer for keeping track of the audio player's current song
    @Published var currentSongObserver: CurrentSongObserver
    
    // Published Array of songs which represents the current playlist being played
    @Published var playlistSongs = [Song]()
    
    // Published boolean to determine whether or not the playerView should be presented
    @Published var isPlayerViewPresented = false
    
    // State TimeInterval variable which is updated by the view's receiver and populates the time slider's duration time for the current playing song
    @Published var currentDuration: TimeInterval = 0
    
    // index of current song in current playing playlist
    private var currentSongIndex: Int = 0
    
    // boolean of whether or not a queued song is playing
    private var queuePlaying = false
    
    // Constructs audioPlayer and its observers
    init() {
        self.audioPlayer = AVQueuePlayer()
        self.timeObserver = TimeObserver(player: AVQueuePlayer())
        self.currentSongObserver = CurrentSongObserver(player: AVQueuePlayer())
    }
    
    // returns current playing song index
    func getCurrentSongIndex() -> Int {
        return currentSongIndex
    }
    
    // returns the audio player's current item
    func getPlayerCurrentItem() -> AVPlayerItem? {
        return audioPlayer.currentItem
    }
    
    // handles a song being added to the queue
    func addToQueue(song: Song) {
        if !queuedSongs.contains(song) {
            queuedSongs.append(song)
        }
    }
    
    // performs seek on the audio player's current playing item
    func playerSeek(currentTime: TimeInterval) {
        // The time slider update is complete and the audio player must now seek to the new current time
        audioPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600)) { _ in
            // Informs the timeObserver that the time slider is done updating and to continue sending time updates
            self.timeObserver.setTimeUpdating(timeUpdating: false)
        }
    }
    
    // Updates audioPlayer's queue to remove songs that have been deleted from the database
    func deleteSong(deleteSong: String)  {
        // updates currentSong index depending on where in the queue the song was deleted
        if let idx = queuedSongs.firstIndex(where: { $0.title! == deleteSong }) {
            // removes the song from queuedSongs array
            queuedSongs.remove(at: idx)
        }
        
        if currentSong != nil {
            // updates currentSong index depending on where in the queue the song was deleted
            if let idx = playlistSongs.firstIndex(where: { $0.title! == deleteSong }) {
                // skips to next song if current song playing is being deleted
                if currentSongIndex == idx {
                    next()
                } else if currentSongIndex > idx {
                    currentSongIndex -= 1
                }
                
                // removes the song from playlistSongs array
                playlistSongs.remove(at: idx)
            }
        }
    }
    
    // pauses audioPlayer's audio and changes the isPlaying state to false
    func pause() {
        audioPlayer.pause()
        isPlaying = false;
    }
    
    // audioPlayer's current song either restarts or goes to the previous song in the current playlist/library
    func previous() {
        // restarts audioPlayer's current song if it has been playing for more than 5 seconds
        let newTime = CMTime(seconds: 5, preferredTimescale: 1)
        if audioPlayer.currentTime() > newTime {
            audioPlayer.seek(to: .zero)
            unPause()
        }
        
        // updates audioPlayer's current song to the previous song in the current playlist/library while keeping audioPlayer's queue consitent with playlistSongs
        else {
            if queuePlaying == false {
                currentSongIndex = max(currentSongIndex - 1, 0)
            }
            let newSong = getNextSong(song: playlistSongs[currentSongIndex])
            audioPlayer.replaceCurrentItem(with: newSong)
            unPause()
        }
    }
    
    // Updates audioPlayer's current song playback time by subtracting 15 seconds
    func goBackward() {
        let currentTime = audioPlayer.currentTime()
        let timeToAdd = CMTimeMakeWithSeconds(15,preferredTimescale: 1)

        let resultTime = CMTimeSubtract(currentTime, timeToAdd)
        audioPlayer.seek(to: CMTimeMaximum(.zero, resultTime))
    }
    
    // Updates audioPlayer's current song playback time by adding 15 seconds
    func goForward() {
        let currentTime = audioPlayer.currentTime()
        let timeToAdd = CMTimeMakeWithSeconds(15,preferredTimescale: 1)

        let resultTime = CMTimeAdd(currentTime,timeToAdd)
        if audioPlayer.currentItem != nil{
            audioPlayer.seek(to: CMTimeMinimum(audioPlayer.currentItem!.duration, resultTime))
        }
    }
    
    // set a new sleep timer and updates sleepTimer state to true
    func sleepTimer(time: TimeInterval){
        timer?.invalidate()
        sleepTimerOn = true
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] timer in
            self?.sleepTimerOn = false
            self?.pause()
        }
    }
    
    // Stops the sleep timer and updates th sleepTimerOn state to false
    func stopTimer(){
        sleepTimerOn = false
        timer?.invalidate()
    }
    
    // updates audioPlayers current song to the next queued song, or if one does not exists then the next song in the current playlist/library
    func next() {
        // adds the next song from queuedSongs (if one exists) to the front of audioPlayer's queue
        if queuedSongs.count != 0 {
            queuePlaying = true
            let newSong = getNextSong(song: queuedSongs.remove(at: 0))
            audioPlayer.replaceCurrentItem(with: newSong)
            unPause()
            return
        }
        
        currentSongIndex += 1
        queuePlaying = false
        
        if currentSongIndex >= playlistSongs.count {
            isPlaying = false
            currentSong = nil
            isPlayerViewPresented = false
            audioPlayer.replaceCurrentItem(with: nil)
            return
        }
        
        // audio player advances to the next song and resumes playing audio
        let newSong = getNextSong(song: playlistSongs[currentSongIndex])
        if newSong != nil{
            audioPlayer.replaceCurrentItem(with: newSong)
            unPause()
        }
    }
    
    // updates audioPlayer with next song to be played
    func getNextSong(song: Song) -> AVPlayerItem? {
        if currentSongIndex >= playlistSongs.count {
            return nil
        }
        return AVPlayerItem(url: Helper.getDocumentsDirectory().appendingPathComponent(song.title!))
    }
    
    // handles request to play a song
    func playSong(id: UUID, fromPlaylist: Bool, songTitle: String) {
        // ignore request if the requested song is audioPlayer's currently playing song
        if audioPlayer.currentItem != nil {
            let asset = audioPlayer.currentItem!.asset
            if let urlAsset = asset as? AVURLAsset {
                if urlAsset.url.lastPathComponent == songTitle {
                    return
                }
            }
        }
        queuePlaying = false
        
        // finds index of song in songs array
        for s in 0...songs.count-1 {
            if songs[s].id == id {
                currentSongIndex = s
                break
            }
        }
        // sets playlistSongs equal to songs array
        playlistSongs = songs
        
        let newSong = getNextSong(song: playlistSongs[currentSongIndex])
        audioPlayer.replaceCurrentItem(with: newSong)
        
        // audioPlayer starts playing the audio and sets isPlaying state to true
        unPause()
        
        // audioPlayer observers for the view components inside PlayerView are reinitialized
        timeObserver = TimeObserver(player: audioPlayer)
        currentSongObserver = CurrentSongObserver(player: audioPlayer)
        
        do {
            // AVAudioSession is initialized
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVSession failed to start")
            return
        }
    }
    
    // unpauses audioPlayer's audio and changes the isPlaying state to true
    func unPause() {
        audioPlayer.play()
        isPlaying = true;
    }
}

