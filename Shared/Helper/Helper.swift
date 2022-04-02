//
//  Helper.swift
//  Offline Music Player (iOS)
//
//  Provides static helper functions to be used throughout the app
//

import Foundation

class Helper {
    // returns the URL to the app's documents directory
    static func getDocumentsDirectory() -> URL {
        // retrieves all document directories for the app
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // returns the first URL, which is the app's document directory
        return paths[0]
    }
    
    // converts an inputted seconds count into a string in the format of mm:ss
    static func formattedTime(_ seconds: Double) -> String {
        // creates formatter and adds required attributes to it
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .positional
        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.zeroFormattingBehavior = [.pad]
        
        // creates and returns formatted time string
        if !seconds.isNaN {
            if let formattedString = dateFormatter.string(from: seconds) {
                return formattedString
            }
        }
        return "00:00"
    }
}
