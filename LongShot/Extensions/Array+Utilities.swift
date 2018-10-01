//
//  Array+Utilities.swift
//  LongShot
//
//  Created by Brandon on 2018-01-05.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension Array {
    public func contains<T: Equatable>(_ element: T) -> Bool {
        return self.contains(where: { (e) -> Bool in
            if let e = e as? T {
                return e == element
            }
            return false
        })
    }
    
    public func contains<T: AnyObject>(_ element: T) -> Bool {
        return self.contains(where: { (e) -> Bool in
            if let e = e as? T {
                return e === element
            }
            return false
        })
    }
    
    public func index<T: Equatable>(of: T) -> Int? {
        return self.index(where: { (e) -> Bool in
            if let e = e as? T {
                return e == of
            }
            return false
        })
    }
    
    public func index<T: AnyObject>(of: T) -> Int? {
        return self.index(where: { (e) -> Bool in
            if let e = e as? T {
                return e === of
            }
            return false
        })
    }
    
    public mutating func remove<T: Equatable>(_ element: T) {
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
    }
    
    public mutating func remove<T: AnyObject>(_ element: T) {
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
    }
    
    public mutating func removeAll<T: Equatable>(_ element: T) {
        var indexes = [Int]()
        for (index, value) in self.enumerated() {
            if let value = value as? T {
                if value == element {
                    indexes.append(index)
                }
            }
        }
        
        var index = 0;
        for i in indexes {
            self.remove(at: i - index)
            index += 1
        }
    }
    
    public mutating func removeAll<T: AnyObject>(_ element: T) {
        var indexes = [Int]()
        for (index, value) in self.enumerated() {
            if let value = value as? T {
                if value === element {
                    indexes.append(index)
                }
            }
        }
        
        var index = 0;
        for i in indexes {
            self.remove(at: i - index)
            index += 1
        }
    }
    
    public mutating func swap(x:[Element]) {
        self.removeAll()
        self.append(contentsOf: x)
    }
    
    public func split(chunks: Int) -> [[Element]] {
        let count = self.count
        var results = [[Element]]()
        
        let length = Int(ceil(Double(count) / Double(chunks)))
        let remainder = count % chunks
        
        var beg = 0
        var end = length
        
        for _ in 0..<(remainder > 0 ? chunks - 1 : chunks) {
            results.append(Array(self[beg..<end]))
            beg += length
            end += length
        }
        
        if remainder > 0 {
            results.append(Array(self[beg..<count]))
        }
        
        return results
    }
}

public extension Array where Element : Equatable {
    public func unique() -> Array {
        return self.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
    }
}

public extension Array where Element : AnyObject {
    public func unique() -> Array {
        return self.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
    }
}

public extension Array where Element : Hashable {
    public func unique() -> Array {
        return self.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
    }
}
