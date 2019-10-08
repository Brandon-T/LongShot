//
//  MemoryMap.swift
//  LongShot
//
//  Created by Brandon on 2018-01-14.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation


/// A class for mapping a file into virtual memory
public class MemoryMap {
    private var hFile: Int32
    private var path: String
    private var pData: UnsafeMutableRawPointer?
    private var pSize: size_t
    private let readOnly: Bool
    
    
    /// MemoryMap constructor
    ///
    /// - Parameters:
    ///   - filePath: The path to the while that will be mapped into the process' address space. If this file does not exist, it is created.
    ///   - size: How much of the much size in bytes to map. If the file doesn't exist, a memory map of the specified size is created.
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
    
    
    /// Opens the memory map file (does not map it immediately into memory). If the file doesn't exist, it is created.
    ///
    /// - Returns: `true` if the file was successfully opened.
	@discardableResult
    public func open() -> Bool {
        var dwFlags = self.readOnly ? O_RDONLY : O_RDWR
        dwFlags |= (!readOnly && self.pSize > 0) ? O_CREAT : 0
        self.hFile = Darwin.open(self.path, dwFlags, S_IRWXU)
        
        if self.hFile != -1 {
            if !self.readOnly && self.pSize > 0 && ftruncate(self.hFile, off_t(self.pSize)) != -1
			{
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
    
    
    /// Maps the specified file into the process' address space.
    ///
    /// - Returns: `true` if the file was successfully mapped.
    public func map() -> Bool {
		self.pData = map(offset: 0, size: self.pSize)
		return self.pData != nil
    }
	
	/// Maps a portion of the specified file into the process' address space.
    ///
    /// - Returns: `UnsafeMutableRawPointer` - A pointer to the portion of the map. `Nil` upon failure.
	public func map(offset: Int, size: Int) -> UnsafeMutableRawPointer! {
        let dwAccess = self.readOnly ? PROT_READ : (PROT_READ | PROT_WRITE);
		let pData = mmap(nil, size, dwAccess, MAP_SHARED, self.hFile, off_t(offset));
		return pData != MAP_FAILED ? pData : nil
    }
    
    
    /// Unmaps the specified file from memory, but does not close it.
    ///
    /// - Returns: `true` if the file was unmapped.
    @discardableResult
    public func unmap() -> Bool {
		let result = unmap(offset: self.pData, size: self.pSize)
		self.pData = nil
		return result
    }
	
	/// Unmaps the specified portion of file from memory, but does not close it.
    ///
    /// - Returns: `true` if the portion of the file was unmapped.
    @discardableResult
    public func unmap(offset: UnsafeMutableRawPointer!, size: Int) -> Bool {
		return munmap(offset, size) == 0;
    }
    
    
    /// Closes the specified file, but does not unmap it from memory.
    ///
    /// - Returns: `true` if the file was closed.
    @discardableResult
    public func close() -> Bool {
        let result = Darwin.close(self.hFile) != -1
        self.hFile = 0;
        return result;
    }
    
    
    /// A Boolean value indicating whether the underlying mapped file is currently open.
    public var isOpen: Bool {
        return self.hFile != 0
    }
    
    
    /// A Boolean value indicating whether the undering file is currently mapped into the process' address space.
    public var isMapped: Bool {
        return self.pData != nil
    }
    
    
    /// The size of the mapped memory file in bytes. This value is `zero` if the file is not currently mapped into memory.
    public var size: UInt32 {
        return self.isMapped ? UInt32(self.pSize) : 0
    }
    
    
    /// A pointer to the beginning of the region of memory at which the file is currently mapped. If the file is not mapped into the process' address space, this value is nil.
    public var data: UnsafeMutableRawPointer? {
        return self.isMapped ? UnsafeMutableRawPointer(self.pData) : nil
    }
	
	public func flush() {
		msync(self.pData, self.pSize, MS_ASYNC)
	}
	
	public func flush(_ ptr: UnsafeMutableRawPointer, size: Int) {
		msync(ptr, size, MS_ASYNC)
	}
    
    
    /// The virtual memory page size of the machine in bytes.
    public class var granularity: Int {
        return sysconf(_SC_PAGESIZE)
    }
    
    
    /// Maps a file into memory with the specified size. If the file doesn't exist, it is created and mapped.
    ///
    /// - Parameters:
    ///   - filePath: The path to the file that should be mapped (or the path of the file to be created -- must include the file name and extension).
    ///   - size: Size of the file to be mapped. If the file doesn't exist, a map is created with this size and written to disk.
    /// - Returns: An instance of `MemoryMap` if the file was mapped successfully; nil otherwise.
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
