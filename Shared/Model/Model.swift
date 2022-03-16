//
//  Model.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-21.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation
import Combine

class Model: ObservableObject {
    @Environment(\.managedObjectContext) private var viewContext
    static let shared = Model()
    
    //var musicPlayer = AudioPlayerManager()
    @Published var queuedSongs = [Song]()
    @Published var playlistSongs = [Song]()
    @Published var songs: [Song] = []
    @Published var isPlaying = false
    @Published var sleepTimerOn = false
    @Published var audioPlayer: AVQueuePlayer
    @Published var playerSongs: [AVPlayerItem] = []
    @Published var currentSongIndex: Int = 0
    @Published var timeObserver: TimeObserver
    @Published var durationObserver: DurationObserver
    @Published var itemObserver: ItemObserver
    @Published var timer: Timer?
    
    init() {
        self.audioPlayer = AVQueuePlayer()
        self.timeObserver = TimeObserver(player: AVQueuePlayer())
        self.durationObserver = DurationObserver(player: AVQueuePlayer())
        self.itemObserver = ItemObserver(player: AVQueuePlayer())
    }
    
    func updateDeleted(deleted: [String])  {
        var removeArr: [AVPlayerItem] = []
        for ind in 0...audioPlayer.items().count-1{
            let asset = self.audioPlayer.items()[ind].asset
            if let urlAsset = asset as? AVURLAsset {
                if deleted.contains(urlAsset.url.lastPathComponent) {
                    removeArr.append(audioPlayer.items()[ind])
                }
            }
        }
        for removeSong in removeArr {
            audioPlayer.remove(removeSong)
        }
    }
    
    func playQueue() {
        do {
            print("play")
            audioPlayer.removeAllItems()
            for s in self.playerSongs {
                self.audioPlayer.insert(s, after: nil)
            }
            self.audioPlayer.play()
            self.timeObserver = TimeObserver(player: audioPlayer)
            self.durationObserver = DurationObserver(player: audioPlayer)
            self.itemObserver = ItemObserver(player: audioPlayer)
            print("sound is playing")
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Sound Play Error -> \(error)")
        }
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func prev() {
        audioPlayer.pause()
        let newTime = CMTime(seconds: 5, preferredTimescale: 1)
        if audioPlayer.currentTime() > newTime {
            audioPlayer.seek(to: .zero)
            audioPlayer.play()
        }
        else {
            if audioPlayer.items().count != 0 {
                let diff = playlistSongs.count - audioPlayer.items().count
                let avSong = AVPlayerItem(url: getDocumentsDirectory().appendingPathComponent(playlistSongs[diff].title!))
                audioPlayer.insert(avSong, after: audioPlayer.items()[0])
                if diff != 0 {
                    let avSong2 = AVPlayerItem(url: getDocumentsDirectory().appendingPathComponent(playlistSongs[diff-1].title!))
                    audioPlayer.insert(avSong2, after: audioPlayer.items()[0])
                }
            } else {
                let avSong = AVPlayerItem(url: getDocumentsDirectory().appendingPathComponent(playlistSongs[-1].title!))
                audioPlayer.insert(avSong, after: nil)
            }
            audioPlayer.advanceToNextItem()
            audioPlayer.play()
        }
    }
    
    func goBackward() {
        let currentTime = audioPlayer.currentTime()
        let timeToAdd = CMTimeMakeWithSeconds(15,preferredTimescale: 1)

        let resultTime = CMTimeSubtract(currentTime, timeToAdd)
        audioPlayer.seek(to: CMTimeMaximum(.zero, resultTime))
    }
    
    func goForward() {
        let currentTime = audioPlayer.currentTime()
        let timeToAdd = CMTimeMakeWithSeconds(15,preferredTimescale: 1)

        let resultTime = CMTimeAdd(currentTime,timeToAdd)
        if audioPlayer.currentItem != nil{
            audioPlayer.seek(to: CMTimeMinimum(audioPlayer.currentItem!.duration, resultTime))
        }
    }
    
    func sleepTimer(time: TimeInterval){
        self.timer?.invalidate()
        self.sleepTimerOn = true
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] timer in
            self?.sleepTimerOn = false
            self?.audioPlayer.pause()
            self?.isPlaying.toggle()
        }
    }
    
    func stopTimer(){
        self.sleepTimerOn = false
        self.timer?.invalidate()
    }
    
    func getSongInd() -> Int {
        let songInd = playlistSongs.count - audioPlayer.items().count - 1
        if songInd < 0{
            return 0
        }
        return songInd
    }
    
    func next() {
        if queuedSongs.count != 0 {
            let newSong = AVPlayerItem(url: getDocumentsDirectory().appendingPathComponent(queuedSongs.remove(at: 0).title!))
            if audioPlayer.items().count == 0{
                audioPlayer.insert(newSong, after: nil)
            } else {
                audioPlayer.insert(newSong, after: audioPlayer.items()[0])
            }
        }
        audioPlayer.advanceToNextItem()
        audioPlayer.play()
    }
    
    func playSong(id: UUID, fromPlaylist: Bool, songTitle: String) {
        
        if audioPlayer.currentItem != nil {
            let asset = self.audioPlayer.currentItem!.asset
            if let urlAsset = asset as? AVURLAsset {
                if urlAsset.url.lastPathComponent == songTitle {
                    audioPlayer.play()
                    return
                }
            }
        }
        var songInd = 0
        print("Songs count: ", songs.count-1)
        for s in 0...songs.count-1 {
            if songs[s].id == id {
                songInd = s
                break
            }
        }
        self.playlistSongs = songs
        self.playerSongs = []
        let count = songInd...songs.count - 1
        for s in count {
            playerSongs.append(AVPlayerItem(url: getDocumentsDirectory().appendingPathComponent(playlistSongs[s].title!)))
        }
        playQueue()
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

