//
//  Model.swift
//  Offline Music Player (iOS)
//
//  This class is used as an environment variable which is passed throughout views within the app and allows the views to use it to manipulate the audio player
//

import Foundation
import AVKit

class Model: ObservableObject {
    // shared instance of model
    static let shared = Model()

    // Audio player
    private var audioPlayer: AVQueuePlayer
    
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
    
    // Array of songs used to popular the audio player when a song from a new playlist/library is played
    private var playerSongs = [AVPlayerItem]()
    
    // Keeps track of the index of the current song playing in the playlistSongs array
    private var currentSongIndex: Int = 0
    
    // Published boolean to determine whether or not the playerView should be presented
    @Published var isPlayerViewPresented = false
    
    // Constructs audioPlayer and its observers
    init() {
        self.audioPlayer = AVQueuePlayer()
        self.timeObserver = TimeObserver(player: AVQueuePlayer())
        self.currentSongObserver = CurrentSongObserver(player: AVQueuePlayer())
    }
    
    // returns the audio player's current item
    func getPlayerCurrentItem() -> AVPlayerItem? {
        return self.audioPlayer.currentItem
    }
    
    // performs seek on the audio player's current playing item
    func playerSeek(currentTime: TimeInterval) {
        // The time slider update is complete and the audio player must now seek to the new current time
        self.audioPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600)) { _ in
            // Informs the timeObserver that the time slider is done updating and to continue sending time updates
            self.timeObserver.setTimeUpdating(timeUpdating: false)
        }
    }
    
    // Updates audioPlayer's queue to remove songs that have been deleted from the database
    func deleteSong(deleteSong: String)  {
        if currentSong != nil {
            let deleted: [String] = [deleteSong]
            var removeArr: [AVPlayerItem] = []
            
            // generates an array of songs from audioPlayer's current queue that need to be removed
            for ind in 0...audioPlayer.items().count-1{
                let asset = self.audioPlayer.items()[ind].asset
                if let urlAsset = asset as? AVURLAsset {
                    if deleted.contains(urlAsset.url.lastPathComponent) {
                        removeArr.append(audioPlayer.items()[ind])
                    }
                }
            }
            // removes the desired songs from the queue
            for removeSong in removeArr {
                self.audioPlayer.remove(removeSong)
            }
            
            // updates currentSong index depending on where in the queue the song was deleted
            if let idx = playlistSongs.firstIndex(where: { $0.title! == deleteSong }) {
                if self.currentSongIndex > idx {
                    self.currentSongIndex = self.currentSongIndex - 1
                } else if self.currentSongIndex == idx {
                    self.audioPlayer.advanceToNextItem()
                }
                
                // removes the song from playlistSongs array
                self.playlistSongs.remove(at: idx)
            }
        }
    }
    
    // Populates audioPlayer's queue with new playlist/library songs and starts playing tge songs
    func playQueue() {
        do {
            // clears all existing songs from audioPlayer's old queue
            audioPlayer.removeAllItems()
            
            // populates audioPlayer's queue with songs from new playlist/library
            for s in self.playerSongs {
                self.audioPlayer.insert(s, after: nil)
            }
            
            // audioPlayer starts playing the audio
            self.audioPlayer.play()
            
            // audioPlayer observers for the view components inside PlayerView are reinitialized
            self.timeObserver = TimeObserver(player: audioPlayer)
            self.currentSongObserver = CurrentSongObserver(player: audioPlayer)
            
            // AVAudioSession is initialized
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Sound Play Error -> \(error)")
        }
    }
    
    // pauses audioPlayer's audio and changes the isPlaying state to false
    func pause() {
        audioPlayer.pause()
        isPlaying = false;
    }
    
    // unpauses audioPlayer's audio and changes the isPlaying state to true
    func unPause() {
        audioPlayer.play()
        isPlaying = true;
    }
    
    // audioPlayer's current song either restarts or goes to the previous song in the current playlist/library
    func prev() {
        audioPlayer.pause()
        // restarts audioPlayer's current song if it has been playing for more than 5 seconds
        let newTime = CMTime(seconds: 5, preferredTimescale: 1)
        if audioPlayer.currentTime() > newTime {
            audioPlayer.seek(to: .zero)
            audioPlayer.play()
            isPlaying = true;
        }
        // updates audioPlayer's current song to the previous song in the current playlist/library while keeping audioPlayer's queue consitent with playlistSongs
        else {
            if audioPlayer.items().count != 0 {
                // inserts the current playing song to the front of the queue
                let diff = playlistSongs.count - audioPlayer.items().count
                let avSong = AVPlayerItem(url: Helper.getDocumentsDirectory().appendingPathComponent(playlistSongs[diff].title!))
                audioPlayer.insert(avSong, after: audioPlayer.items()[0])
                
                // if the current song is not the first song in the playlist then add the song prior to it in playlistSongs to the front of the queue
                if diff != 0 {
                    let avSong2 = AVPlayerItem(url: Helper.getDocumentsDirectory().appendingPathComponent(playlistSongs[diff-1].title!))
                    audioPlayer.insert(avSong2, after: audioPlayer.items()[0])
                }
            } else {
                // inserts the last song in the playlist
                let avSong = AVPlayerItem(url: Helper.getDocumentsDirectory().appendingPathComponent(playlistSongs[-1].title!))
                audioPlayer.insert(avSong, after: nil)
            }
            // audioPlayer resumess playing audio
            audioPlayer.advanceToNextItem()
            audioPlayer.play()
            isPlaying = true;
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
        self.timer?.invalidate()
        self.sleepTimerOn = true
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] timer in
            self?.sleepTimerOn = false
            self?.pause()
        }
    }
    
    // Stops the sleep timer and updates th sleepTimerOn state to false
    func stopTimer(){
        self.sleepTimerOn = false
        self.timer?.invalidate()
    }
    
    // finds index of the current song playing in the playlistSongs array
    func getSongInd() -> Int {
        let songInd = playlistSongs.count - audioPlayer.items().count - 1
        if songInd < 0{
            return 0
        }
        return songInd
    }
    
    // updates audioPlayers current song to the next queued song, or if one does not exists then the next song in the current playlist/library
    func next() {
        // adds the next song from queuedSongs (if one exists) to the front of audioPlayer's queue
        if queuedSongs.count != 0 {
            let newSong = AVPlayerItem(url: Helper.getDocumentsDirectory().appendingPathComponent(queuedSongs.remove(at: 0).title!))
            if audioPlayer.items().count == 0{
                audioPlayer.insert(newSong, after: nil)
            } else {
                audioPlayer.insert(newSong, after: audioPlayer.items()[0])
            }
        }
        // audio player advances to the next song and resumes playing audio
        audioPlayer.advanceToNextItem()
        if audioPlayer.currentItem != nil{
            audioPlayer.play()
            isPlaying = true;
        }
    }
    
    // handles request to play a song
    func playSong(id: UUID, fromPlaylist: Bool, songTitle: String) {
        // ignore request if the requested song is audioPlayer's currently playing song
        if audioPlayer.currentItem != nil {
            let asset = self.audioPlayer.currentItem!.asset
            if let urlAsset = asset as? AVURLAsset {
                if urlAsset.url.lastPathComponent == songTitle {
                    return
                }
            }
        }
        // finds index of song in songs array
        var songInd = 0
        print("Songs count: ", songs.count-1)
        for s in 0...songs.count-1 {
            if songs[s].id == id {
                songInd = s
                break
            }
        }
        // sets playlistSongs equal to songs array
        self.playlistSongs = songs
        self.playerSongs = []
        let count = songInd...songs.count - 1
        
        // populates the playerSongs array with new playlist/library songs
        for s in count {
            playerSongs.append(AVPlayerItem(url: Helper.getDocumentsDirectory().appendingPathComponent(playlistSongs[s].title!)))
        }
        
        // calls playQueue to reinitialize audioPlayer with new songs and resume playing
        playQueue()
        isPlaying = true;
    }
}

