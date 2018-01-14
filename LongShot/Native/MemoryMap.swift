//
//  MemoryMap.swift
//  LongShot
//
//  Created by Brandon on 2018-01-14.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public class MemoryMap {
    private var hFile: Int32
    private var path: String
    private var pData: UnsafeMutableRawPointer?
    private var pSize: size_t
    private let readOnly: Bool
    
    public init(filePath: String, size: UInt32) {
        self.hFile = 0
        self.path = filePath
        self.pData = nil
        self.pSize = size_t(size)
        self.readOnly = false
    }
    
    deinit {
        self.unmap()
        self.close()
    }
    
    public func open() -> Bool {
        var dwFlags = self.readOnly ? O_RDONLY : O_RDWR
        dwFlags |= (!readOnly && self.pSize > 0) ? (O_CREAT | O_TRUNC) : 0
        self.hFile = Darwin.open(self.path, dwFlags, S_IRWXU)
        
        if self.hFile != -1 {
            if !self.readOnly && self.pSize > 0 && ftruncate(self.hFile, off_t(self.pSize)) != -1 {
                var info: stat = stat()
                return fstat(self.hFile, &info) != -1 ? self.pSize == info.st_size : false;
            }
            
            self.pSize = 0;
            var info: stat = stat()
            if (fstat(self.hFile, &info) != -1)
            {
                self.pSize = size_t(info.st_size);
                return true;
            }
        }
        return false;
    }
    
    public func map() -> Bool {
        if self.pData == nil {
            let dwAccess = self.readOnly ? PROT_READ : (PROT_READ | PROT_WRITE);
            self.pData = mmap(nil, self.pSize, dwAccess, MAP_SHARED, self.hFile, 0);
            return self.pData != MAP_FAILED;
        }
        return true
    }
    
    @discardableResult
    public func unmap() -> Bool {
        let result = munmap(self.pData, self.pSize) == 0;
        self.pData = nil
        return result;
    }
    
    @discardableResult
    public func close() -> Bool {
        let result = Darwin.close(self.hFile) != -1
        self.hFile = 0;
        return result;
    }
    
    public func isOpen() -> Bool {
        return self.hFile != 0
    }
    
    public func isMapped() -> Bool {
        return self.pData != nil
    }
    
    public func size() -> UInt32 {
        return UInt32(self.pSize)
    }
    
    public func data() -> UnsafeMutableRawPointer? {
        return UnsafeMutableRawPointer(self.pData)
    }
    
    public func granulariy() -> Int {
        return sysconf(_SC_PAGESIZE)
    }
    
    public class func mapFile(filePath: String, size: UInt32) -> MemoryMap? {
        let memoryMap = MemoryMap(filePath: filePath, size: size)
        if memoryMap.open() {
            if memoryMap.map() {
                return memoryMap
            }
        }
        return nil
    }
}
