//
//  ContentView.swift
//  Offline Music Player (iOS)
//
//  The first view that is loaded by the apps main function, which controls the menu tab selections and the Player views 
//

import SwiftUI
import AVKit

struct ContentView: View {
    // creates environment variable to be used throughout the app
    @ObservedObject var model = Model.shared
    
    // persistent storage context
    @Environment(\.managedObjectContext) private var viewContext
    
    // Set reccuring timer to constantly check and update the model's currentSong property used by BarPlayerView to display the current song playing
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    // State Int to track of the currently selected app menu tab
    @State private var tab = 0
    
    @State private var playerYOffset = CGSize.zero
    
    @State private var barYOffset = CGSize.zero
    
    @State private var barYDragging = false
    
    var body: some View{
        ZStack {
            // App's menu tab at the bottom of the screen
            TabView(selection: $tab) {
                // Library tab
                ZStack() {
                    LibraryView()
                        .environmentObject(model)
                }
                .tabItem {
                    VStack {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                }
                .tag(0)
                
                // Playlist Tab
                ZStack {
                    PlaylistView()
                        .environmentObject(model)
                }
                .tabItem {
                    VStack {
                        Image(systemName: "music.note.list")
                        Text("Playlists")
                    }
                }
                .tag(1)
                
                // Queue tab
                ZStack {
                    QueueView()
                        .environmentObject(model)
                }
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("Queue")
                    }
                }
                .tag(2)
            }
            .padding(.top, 5)
            
            // Displays either BarPlayerView or PlayerView when a song is being played
            Group {
                Group {
                    if model.isPlayerViewPresented == false {
                        BarPlayerView()
                            .environmentObject(model)
                            .offset(x: 0, y: barYOffset.height - 49)
                            .opacity(2 - Double(abs(barYOffset.height)/100))
                    }
                    
                    if model.isPlayerViewPresented || barYDragging {
                        PlayerView()
                            .environmentObject(model)
                            .offset(x: 0, y: model.isPlayerViewPresented ? playerYOffset.height : (barYOffset.height - 49 + UIScreen.main.bounds.height))
                            .opacity(1.5 - Double(playerYOffset.height/300))
                            .gesture(
                                DragGesture()
                                    // If the view is being dragged down, update the offset value
                                    .onChanged { gesture in
                                        if gesture.translation.height > CGSize(width: 0, height: 20).height {
                                            playerYOffset = gesture.translation
                                        }
                                    }
                                    // When the drag gesture has been completed, update the isPlayerViewPresented variable if the view was dragged down far enough or otherwise reset the offset to 0
                                    .onEnded { _ in
                                        if playerYOffset.height > 200 {
                                            withAnimation {
                                                model.isPlayerViewPresented = false
                                            }
                                            playerYOffset = .zero
                                        }
                                        else {
                                            withAnimation {
                                                playerYOffset = .zero
                                            }
                                        }
                                    }
                            )
                    }
                }
                .gesture(
                    DragGesture()
                        // If the view is being dragged down, update the offset value
                        .onChanged { gesture in
                            barYDragging = true
                            barYOffset = gesture.translation
                        }
                        // When the drag gesture has been completed, update the isPlayerViewPresented variable if the view was dragged down far enough or otherwise reset the offset to 0
                        .onEnded { _ in
                            if barYOffset.height < -200 {
                                withAnimation {
                                    model.isPlayerViewPresented = true
                                }
                                barYOffset = .zero
                            }
                            else {
                                withAnimation {
                                    barYOffset = .zero
                                }
                            }
                            barYDragging = false
                        }
                )
            }
        }
        // gives buttons and icons pink tint
        .accentColor(.pink)
        // receives each time the timer publshes in order to update the model's currentSong and currentDuration property if necessary
        .onReceive(timer) { _ in
            if model.getPlayerCurrentItem() != nil {
                // updates model's currentDuration if it is different from the current playing song's duration
                if model.getPlayerCurrentItem()!.duration.isNumeric {
                    if model.currentDuration != model.getPlayerCurrentItem()!.duration.seconds {
                        model.currentDuration = TimeInterval(model.getPlayerCurrentItem()!.duration.seconds)
                    }
                }
                let asset = model.getPlayerCurrentItem()!.asset
                if let urlAsset = asset as? AVURLAsset {
                    // updates model's currentSong if it is different from the current playing song
                    if model.currentSong != urlAsset.url.lastPathComponent {
                        model.currentSong = urlAsset.url.lastPathComponent
                    }
                }
            }
        }
    }
}
