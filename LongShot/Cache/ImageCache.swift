//
//  ImageCache.swift
//  LongShot
//
//  Created by Brandon on 2018-01-16.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

public class ImageCache {
    private let format: ImageFormat
	private let maxEntries: UInt32
	private let memoryMap: MemoryMap
    
	public init(maxEntries: UInt32, format: ImageFormat = .small) {
		let directoryPath = ImageCache.getDirectory()
		let filePath = (directoryPath as NSString).appendingPathComponent("\(format.id).cache")
		let imageSize = ImageCache.align(Int(CGFloat(format.width) * UIScreen.main.scale * CGFloat(format.bytesPerPixel)), 64) * Int(CGFloat(format.height) * UIScreen.main.scale)
		
		if !FileManager.default.fileExists(atPath: filePath) {
			try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
			FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
		
        self.format = format
		self.maxEntries = maxEntries
		self.memoryMap = MemoryMap(filePath: filePath, size: UInt32(ImageCache.align(imageSize, MemoryMap.granularity)) * maxEntries)
		
		ImageMetadata.createCacheMetadata(path: (directoryPath as NSString).appendingPathComponent("\(format.id).metadata"), maxEntries: maxEntries, format: format)
		print("OPENED: \(self.memoryMap.open())")
    }
    
    private class func getDirectory() -> String {
        var directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
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
			let filePath = (directoryPath as NSString).appendingPathComponent("\(self.format.id).cache")
            return FileManager().fileExists(atPath: filePath)
        }
        return false
    }
	
	internal class func align(_ width: Int, _ alignment: Int) -> Int {
		return ((width + (alignment - 1)) / alignment) * alignment
	}
	
	public func hasImage(for url: String) -> Bool {
		return ImageMetadata.get(url: url) != nil
	}
	
	public func image(for url: String) -> UIImage? {
		guard let imageMetaData = ImageMetadata.get(url: url) else {
			return nil
		}
		
		let width = Int(CGFloat(format.width) * UIScreen.main.scale)
		let height = Int(CGFloat(format.height) * UIScreen.main.scale)
		let rowLength = ImageCache.align(width * Int(format.bytesPerPixel), 64)
		
		let imageSize = rowLength * height
		guard let ptr = memoryMap.map(offset: imageMetaData.offset, size: imageSize) else { return nil }
		let dataProvider = CGDataProvider(dataInfo: nil, data: ptr, size: imageSize) { info, data, size in
		}
		
		let colourSpace = CGColorSpaceCreateDeviceRGB()
		let image = CGImage(width: Int(width),
							height: Int(height),
							bitsPerComponent: Int(format.bitsPerComponent),
							bitsPerPixel: Int(format.bytesPerPixel) * 8,
							bytesPerRow: rowLength,
							space: colourSpace,
							bitmapInfo: createBitmapInfo(),
							provider: dataProvider!,
							decode: nil,
							shouldInterpolate: false,
							intent: .defaultIntent)
		
		return UIImage(cgImage: image!, scale: UIScreen.main.scale, orientation: .up)
	}
	
	public func setImage(for url: String, image: UIImage) {
		let offset = ImageMetadata.getAvailableSlot(for: url)
		ImageMetadata.setAvailableSlot(offset: offset, url: url)
		
		if offset == -1 {
			print("CACHE IS FULL!! DO SOMETHING!")
		}
		
		let imageMetaData = ImageMetadata(url: url, width: Int(image.size.width), height: Int(image.size.height), offset: offset, cacheId: format.id)
		ImageMetadata.insert(metadata: imageMetaData)
		
		let width = Int(CGFloat(format.width) * UIScreen.main.scale)
		let height = Int(CGFloat(format.height) * UIScreen.main.scale)
		let rowLength = ImageCache.align(width * Int(format.bytesPerPixel), 64)
		
		let imageSize = rowLength * height
		guard let ptr = memoryMap.map(offset: offset, size: imageSize) else { return }
		
		let bounds = CGRect(origin: .zero, size: CGSize(width: Int(format.width), height: Int(format.height)))
		
		let colourSpace = CGColorSpaceCreateDeviceRGB()
		let context = CGContext(data: ptr,
								width: width,
								height: height,
								bitsPerComponent: Int(format.bitsPerComponent),
								bytesPerRow: rowLength,
								space: colourSpace,
								bitmapInfo: createBitmapInfo().rawValue)!
		
		context.translateBy(x: 0.0, y: CGFloat(height))
		context.scaleBy(x: UIScreen.main.scale, y: -UIScreen.main.scale)
		context.clear(bounds)
		
		UIGraphicsPushContext(context)
		context.draw(image.cgImage!, in: bounds)
		UIGraphicsPopContext()
		memoryMap.flush(ptr, size: imageSize)
		memoryMap.unmap(offset: ptr, size: imageSize)
	}
	
	private func createBitmapInfo() -> CGBitmapInfo {
		var hostByteOrder: CGBitmapInfo {
			return CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) ? CGBitmapInfo.byteOrder32Little : CGBitmapInfo.byteOrder32Big
		}
		
		return CGBitmapInfo(rawValue: hostByteOrder.rawValue).union(
			CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
		)
	}
}

struct ImageMetadata {
	let url: String
	let width: Int
	let height: Int
	let offset: Int
	let cacheId: String
	
	static func createCacheMetadata(path: String, maxEntries: UInt32, format: ImageFormat) {
		let dbPath = ImageMetadata.dbPath
		
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }
			
			let imageTable = "CREATE TABLE IF NOT EXISTS ImageMetaData (URL TEXT PRIMARY KEY, WIDTH INTEGER, HEIGHT INTEGER, OFFSET INTEGER, CACHE_ID TEXT);"
			
			var cursor: OpaquePointer?
			if sqlite3_prepare_v2(db, imageTable, -1, &cursor, nil) == SQLITE_OK {
				sqlite3_step(cursor)
				sqlite3_finalize(cursor)
			}
			
			let indexTable = "CREATE TABLE IF NOT EXISTS ImageMetaIndex (OFFSET INTEGER PRIMARY KEY NOT NULL, URL TEXT);"
			if sqlite3_prepare_v2(db, indexTable, -1, &cursor, nil) == SQLITE_OK {
				sqlite3_step(cursor)
				sqlite3_finalize(cursor)
				
				let imageSize = ImageCache.align(Int(CGFloat(format.width) * UIScreen.main.scale * CGFloat(format.bytesPerPixel)), 64) * Int(CGFloat(format.height) * UIScreen.main.scale)
				
				for i in 0..<maxEntries {
					let statement = "INSERT INTO ImageMetaIndex (OFFSET, URL) VALUES(?, ?);"
					if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
						sqlite3_bind_int64(cursor, 1, Int64(Int(i) * imageSize))
						sqlite3_bind_null(cursor, 2)
						sqlite3_step(cursor)
						sqlite3_finalize(cursor)
					}
				}
			}
		}
	}
	
	private static var dbPath: String {
		let dirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
		return (dirPath as NSString).appendingPathComponent("medium.metadata")
	}
	
	static func getAvailableSlot(for url: String) -> Int {
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }

			let match = "SELECT OFFSET FROM ImageMetaIndex WHERE URL = '\(url)';"
			var cursor: OpaquePointer?
			if sqlite3_prepare_v2(db, match, -1, &cursor, nil) == SQLITE_OK {
				while sqlite3_step(cursor) == SQLITE_ROW {
					let offset = sqlite3_column_int64(cursor, 0)
					sqlite3_finalize(cursor)
					return Int(offset)
				}
				sqlite3_finalize(cursor)
			}
			
			let statement = "SELECT OFFSET FROM ImageMetaIndex WHERE URL IS NULL;"
			if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
				while sqlite3_step(cursor) == SQLITE_ROW {
					let offset = sqlite3_column_int64(cursor, 0)
					sqlite3_finalize(cursor)
					return Int(offset)
				}
				sqlite3_finalize(cursor)
			}
		}
		return -1
	}
	
	static func setAvailableSlot(offset: Int, url: String?) {
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }

			if let url = url {
				let statement = "UPDATE ImageMetaIndex SET URL = '\(url)' WHERE OFFSET = \(offset);"
				var cursor: OpaquePointer?
				if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
					sqlite3_step(cursor)
					sqlite3_finalize(cursor)
				}
			}
			else {
				let statement = "UPDATE ImageMetaIndex SET URL IS NULL WHERE OFFSET = \(offset);"
				var cursor: OpaquePointer?
				if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
					sqlite3_step(cursor)
					sqlite3_finalize(cursor)
				}
			}
		}
	}
	
	public static func insert(metadata: ImageMetadata) {
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }
			let statement = "INSERT INTO ImageMetaData (URL, WIDTH, HEIGHT, OFFSET, CACHE_ID) VALUES(?, ?, ?, ?, ?);"
			var cursor: OpaquePointer?
			if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
				sqlite3_bind_text(cursor, 1, metadata.url, -1, nil)
				sqlite3_bind_int(cursor, 2, Int32(metadata.width))
				sqlite3_bind_int(cursor, 3, Int32(metadata.height))
				sqlite3_bind_int(cursor, 4, Int32(metadata.offset))
				sqlite3_bind_text(cursor, 5, metadata.cacheId, -1, nil)
				sqlite3_step(cursor)
				sqlite3_finalize(cursor)
			}
		}
	}
	
	public static func update(metadata: ImageMetadata) {
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }
			let statement = "UPDATE ImageMetaData SET (URL, WIDTH, HEIGHT, OFFSET, CACHE_ID) VALUES(?, ? ?, ?, ?, ?, ?);"
			var cursor: OpaquePointer?
			if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
				sqlite3_bind_text(cursor, 1, metadata.url, -1, nil)
				sqlite3_bind_int(cursor, 2, Int32(metadata.width))
				sqlite3_bind_int(cursor, 3, Int32(metadata.height))
				sqlite3_bind_int(cursor, 4, Int32(metadata.offset))
				sqlite3_bind_text(cursor, 5, metadata.cacheId, -1, nil)
				sqlite3_step(cursor)
				sqlite3_finalize(cursor)
			}
		}
	}
	
	public static func get(url: String) -> ImageMetadata? {
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }
			var cursor: OpaquePointer? = nil
			let statement = "SELECT * FROM ImageMetaData WHERE URL = '\(url)';"
			if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_OK {
				if sqlite3_step(cursor) == SQLITE_ROW {
					let url = sqlite3_column_text(cursor, 0)!
					let width = sqlite3_column_int(cursor, 1)
					let height = sqlite3_column_int(cursor, 2)
					let offset = sqlite3_column_int(cursor, 3)
					let cache_id = sqlite3_column_text(cursor, 4)!
					sqlite3_finalize(cursor)
					
					return ImageMetadata(url: String(cString: url), width: Int(width), height: Int(height), offset: Int(offset), cacheId: String(cString: cache_id))
				}
			}
		}
		return nil
	}
	
	public static func delete(url: String) {
		var db: OpaquePointer?
		if sqlite3_open(dbPath, &db) == SQLITE_OK {
			defer { sqlite3_close(db) }
			var cursor: OpaquePointer? = nil
			let statement = "DELETE FROM ImageMetaData WHERE URL = '\(url)';"
			if sqlite3_prepare_v2(db, statement, -1, &cursor, nil) == SQLITE_DONE {
				defer { sqlite3_finalize(cursor) }
				if sqlite3_step(cursor) == SQLITE_DONE {
				}
			}
		}
	}
}

public struct ImageFormat {
	let id: String
	let width: Int16
	let height: Int16
	let bytesPerPixel: Int16
	let bitsPerComponent: Int16
	let hasAlpha: Bool
	
	public static let xxs = ImageFormat(id: "xs", width: 64, height: 64, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
	
	public static let xs = ImageFormat(id: "xs", width: 128, height: 128, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
	
	public static let small = ImageFormat(id: "small", width: 256, height: 256, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
	
	public static let medium = ImageFormat(id: "medium", width: 512, height: 512, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
	
	public static let large = ImageFormat(id: "large", width: 1024, height: 1024, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
	
	public static let xl = ImageFormat(id: "xl", width: 2048, height: 2048, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
	
	public static let xxl = ImageFormat(id: "xxl", width: 4096, height: 4096, bytesPerPixel: 4, bitsPerComponent: 8, hasAlpha: true)
}
