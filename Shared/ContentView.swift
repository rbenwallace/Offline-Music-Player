//
//  ContentView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2021-11-11.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var model = Model.shared
    @Environment(\.managedObjectContext) private var viewContext
    @State var selection = 0
    
    var body: some View{
        TabView(selection: $selection) {
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
            
            ZStack {
                QueueView()
                    .environmentObject(model)
            }
            .tabItem {
                VStack {
                    Image(systemName: "music.note.list")
                    Text("Queue")
                }
            }
            .tag(2)
        }
    }
}
