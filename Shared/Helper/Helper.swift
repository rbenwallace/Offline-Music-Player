//
//  Helper.swift
//  Offline Music Player (iOS)
//
//  Provides static helper functions to be used throughout the app
//

import Foundation
import SwiftUI

class Helper {
    // Defines the main three system colours used in the app's views based on the user's system background colour settings
    static let primaryBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // returns the opposite colour of the systems background colour to use for a view's font colour
    static func getFontColour(colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? .white : .black
    }
    
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
