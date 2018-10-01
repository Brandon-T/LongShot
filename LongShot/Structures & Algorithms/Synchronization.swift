//
//  Synchronization.swift
//  LongShot
//
//  Created by Brandon on 2018-09-30.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

final class Mutex {
    class func synchronized(lock: Any, action: () -> Void) {
        objc_sync_enter(lock)
        action()
        objc_sync_exit(lock)
    }
}
