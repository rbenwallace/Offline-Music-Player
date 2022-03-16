//
//  AddPlaylistSongsView.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-02-26.
//

import SwiftUI
import CoreData

struct AddPlaylistSongsView: View {
    @EnvironmentObject var model: Model
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var isAdding: Bool
    @State var availableSongs: [Song]
    @State var selections: [Song] = []
    public var playlist: Playlist

    var body: some View {
        List {
            ForEach(self.availableSongs, id: \.self) { item in
                MultipleSelectionRow(title: item.unwrappedTitle, isSelected: self.selections.contains(where: { $0.id == item.id })) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.isAdding.toggle()
                }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    for s in self.selections {
                        self.playlist.addToSongs(s)
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    self.isAdding.toggle()
                }) {
                    Text("Add")
                }
            }
            
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
