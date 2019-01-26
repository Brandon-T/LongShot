//
//  OrderedDictionary.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public struct OrderedDictionary<Key: Hashable, Value>: ExpressibleByDictionaryLiteral {
    public private (set) var keys = [Key]()
    private var values = [Key: Value]()
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for element in elements {
            self[element.0] = element.1
        }
    }
    
    public var isEmpty: Bool {
        return self.keys.isEmpty
    }
    
    public var count: Int {
        assert(keys.count == values.count, "The number of Keys is different from the number of values")
        return self.keys.count
    }
    
    public subscript(index: Int) -> Value? {
        get {
            return self.values[self.keys[index]]
        }
        
        set (newValue) {
            let key = self.keys[index]
            if newValue != nil {
                self.values[key] = newValue
            } else {
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
                self.keys = self.keys.filter({ $0 != key })
            } else {
                let oldValue = self.values.updateValue(newValue!, forKey: key) //swiftlint:disable:this force_unwrapping
                if oldValue == nil {
                    self.keys.append(key)
                }
            }
        }
    }
    
    public mutating func removeAll() {
        self.keys.removeAll()
        self.values.removeAll()
    }
}

extension OrderedDictionary: Sequence where Key: Hashable {
    public func makeIterator() -> AnyIterator<(Key, Value)> {
        var index = 0
        
        return AnyIterator {
            if index < self.count {
                let key = self.keys[index]
                let value = self.values[key]! //swiftlint:disable:this force_unwrapping
                index += 1
                return (key, value)
            }
            
            return nil
        }
    }
}

extension OrderedDictionary: Encodable where Key: Encodable, Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        if Key.self == String.self {
            // Since the keys are already Strings, we can use them as keys directly.
            var container = encoder.container(keyedBy: OrderedDictionaryCodingKey.self)
            for (key, value) in self {
                let codingKey = OrderedDictionaryCodingKey(stringValue: key as! String)! //swiftlint:disable:this force_cast force_unwrapping
                try container.encode(value, forKey: codingKey)
            }
        } else if Key.self == Int.self {
            // Since the keys are already Ints, we can use them as keys directly.
            var container = encoder.container(keyedBy: OrderedDictionaryCodingKey.self)
            for (key, value) in self {
                let codingKey = OrderedDictionaryCodingKey(intValue: key as! Int)! //swiftlint:disable:this force_cast force_unwrapping
                try container.encode(value, forKey: codingKey)
            }
        } else {
            // Keys are Encodable but not Strings or Ints, so we cannot arbitrarily
            // convert to keys. We can encode as an array of alternating key-value
            // pairs, though.
            var container = encoder.unkeyedContainer()
            for (key, value) in self {
                try container.encode(key)
                try container.encode(value)
            }
        }
    }
}

extension OrderedDictionary: Decodable where Key: Decodable, Value: Decodable {
    public init(from decoder: Decoder) throws {
        self.init()
        
        if Key.self == String.self {
            let container = try decoder.container(keyedBy: OrderedDictionaryCodingKey.self)
            for key in container.allKeys {
                let value = try container.decode(Value.self, forKey: key)
                self[key.stringValue as! Key] = value //swiftlint:disable:this force_cast
            }
        } else if Key.self == Int.self {
            let container = try decoder.container(keyedBy: OrderedDictionaryCodingKey.self)
            for key in container.allKeys {
                guard key.intValue != nil else {
                    var codingPath = decoder.codingPath
                    codingPath.append(key)
                    throw DecodingError.typeMismatch(
                        Int.self, DecodingError.Context(
                            codingPath: codingPath,
                            debugDescription: "Expected Int key but found String key instead."))
                }
                
                let value = try container.decode(Value.self, forKey: key)
                self[key.intValue! as! Key] = value //swiftlint:disable:this force_cast force_unwrapping
            }
        } else {
            var container = try decoder.unkeyedContainer()
            if let count = container.count {
                guard count % 2 == 0 else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected collection of key-value pairs; encountered odd-length array instead."))
                }
            }
            
            while !container.isAtEnd {
                let key = try container.decode(Key.self)
                
                guard !container.isAtEnd else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Unkeyed container reached end before value in key-value pair."))
                }
                
                let value = try container.decode(Value.self)
                self[key] = value
            }
        }
    }
}

internal struct OrderedDictionaryCodingKey: CodingKey {
    internal let stringValue: String
    internal let intValue: Int?
    
    internal init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }
    
    internal init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
