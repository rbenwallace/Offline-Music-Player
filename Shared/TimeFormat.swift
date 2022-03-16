//
//  Utility.swift
//  Offline Cloud Music Player
//
//  Created by Ben Wallace on 2022-03-07.
//

import Foundation

class TimeFormat: NSObject {
    
    private static var timeHMSFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    static func formatSecondsToHMS(_ seconds: Double) -> String {
        guard !seconds.isNaN,
            let text = timeHMSFormatter.string(from: seconds) else {
                return "00:00"
        }
         
        return text
    }
    
}
