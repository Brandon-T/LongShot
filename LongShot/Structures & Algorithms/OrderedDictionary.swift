//
//  OrderedDictionary.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public class OrderedDictionary<Key: Hashable, Value> : ExpressibleByDictionaryLiteral {
    public private (set) var keys = Array<Key>()
    private var values = Dictionary<Key, Value>()
    
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        for element in elements {
            self[element.0] = element.1
        }
    }
    
    public var count: Int {
        assert(keys.count == values.count, "The number of Keys is different from the number of values")
        return self.keys.count;
    }
    
    public subscript(index: Int) -> Value? {
        get {
            return self.values[self.keys[index]]
        }
        
        set (newValue) {
            let key = self.keys[index]
            if newValue != nil {
                self.values[key] = newValue
            }
            else {
                self.values.removeValue(forKey: key)
                self.keys.remove(at: index)
            }
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return self.values[key]
        }
        
        set (newValue) {
            if newValue == nil {
                self.values.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            }
            else {
                let oldValue = self.values.updateValue(newValue!, forKey: key)
                if oldValue == nil {
                    self.keys.append(key)
                }
            }
        }
    }
    
    public func removeAll() -> Void {
        self.keys.removeAll()
        self.values.removeAll()
    }
}
