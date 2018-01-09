//
//  AudioPlayer.swift
//  LongShot
//
//  Created by Brandon on 2018-01-07.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    private let player: AVQueuePlayer!
    
    init() {
        self.player = AVQueuePlayer()
    }
}
