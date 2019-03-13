//
//  InputStream.swift
//  LongShot
//
//  Created by Brandon on 2019-03-12.
//  Copyright © 2019 XIO. All rights reserved.
//

import Foundation

extension InputStream {
    /**
     * Reads from the stream into a data buffer.
     * Returns the count of the amount of bytes read from the stream.
     * Returns -1 if reading fails or an error has occurred on the stream.
     **/
    func read(data: inout Data) -> Int {
        let bufferSize = 1024
        var totalBytesRead = 0
        
        while true {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            let count = read(buffer, maxLength: bufferSize)
            if count == 0 {
                return totalBytesRead
            }
            
            if count == -1 {
                if let streamError = self.streamError {
                    debugPrint("Stream Error: \(String(describing: streamError))")
                }
                return -1
            }
            
            data.append(buffer, count: count)
            totalBytesRead += count
        }
        return totalBytesRead
    }
}




//var readStream: Unmanaged<CFReadStream>?
//var writeStream: Unmanaged<CFWriteStream>?
//
//CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "127.0.0.1" as CFString, 2323, &readStream, &writeStream)
//
//
//var inputStream = readStream!.takeRetainedValue() as InputStream
//var outputStream = writeStream!.takeRetainedValue() as OutputStream
//
//inputStream.schedule(in: .current, forMode: .common)
//outputStream.schedule(in: .current, forMode: .common)
//
//inputStream.open()
//outputStream.open()
//
//
//var dataToWrite = Data() //Your Image
//var dataRead = Data(capacity: 256) //Server response -- Pre-Allocate something large enough that you "think" you might read..
//
//outputStream.write(data: dataToWrite)
//inputStream.read(data: &dataRead)
