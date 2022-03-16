//
//  DurationObserver.swift
//  Offline Music Player (iOS)
//
//  Created by Ben Wallace on 2022-03-16.
//

import AVKit
import Combine

class DurationObserver {
    let publisher = PassthroughSubject<TimeInterval, Never>()
    private var cancellable: AnyCancellable?
    
    init(player: AVQueuePlayer) {
        let durationKeyPath: KeyPath<AVQueuePlayer, CMTime?> = \.currentItem?.duration
        cancellable = player.publisher(for: durationKeyPath).sink { duration in
            guard let duration = duration else { return }
            guard duration.isNumeric else { return }
            self.publisher.send(duration.seconds)
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
}
