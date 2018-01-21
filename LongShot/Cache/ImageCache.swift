//
//  ImageCache.swift
//  LongShot
//
//  Created by Brandon on 2018-01-16.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    private var memoryMap: MemoryMap?
    private let identifier: String
    
    init(cacheSize: UInt32, identifier: String) {
        self.identifier = identifier
    }
    
    private class func getDirectory() -> String {
        var directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false).first!
        directory = (directory as NSString).appendingPathComponent("LongShotImageCache")
        return directory
    }
    
    private class func directoryExists() -> Bool {
        let directoryPath = self.getDirectory()
        return FileManager().fileExists(atPath: directoryPath)
    }
    
    private func cacheExists() -> Bool {
        if ImageCache.directoryExists() {
            let directoryPath = ImageCache.getDirectory()
            let filePath = (directoryPath as NSString).appendingPathComponent("\(self.identifier).cache")
            return FileManager().fileExists(atPath: filePath)
        }
        return false
    }
}

extension UIImage {
    func imageFromMemory(memory: MemoryMap) {
        
    }
}
