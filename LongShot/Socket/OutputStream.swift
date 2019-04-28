//
//  OutputStream.swift
//  LongShot
//
//  Created by Brandon on 2019-03-12.
//  Copyright © 2019 XIO. All rights reserved.
//

import Foundation

extension OutputStream {
    /**
     * Writes from a buffer into the stream.
     * Returns the count of the amount of bytes written to the stream.
     * Returns -1 if writing fails or an error has occurred on the stream.
     **/
    func write(data: Data) -> Int {
        var bytesRemaining = data.count
        var bytesWritten = 0
        
        while bytesRemaining > 0 {
            let count = data.withUnsafeBytes {
                self.write($0.baseAddress!.assumingMemoryBound(to: UInt8.self).advanced(by: bytesWritten), maxLength: bytesRemaining)
            }
            
            if count == 0 {
                return bytesWritten
            }
            
            if count < 0 {
                if let streamError = self.streamError {
                    debugPrint("Stream Error: \(String(describing: streamError))")
                }
                return -1
            }
            
            bytesRemaining -= count
            bytesWritten += count
        }
        
        return bytesWritten
    }
}
