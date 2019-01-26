//
//  KeyPaths.swift
//  LongShot
//
//  Created by Brandon on 2018-10-10.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public struct KeyPath {
    public init(_ string: String) {
        parts = string.components(separatedBy: ".")
    }
    
    internal init(parts: [String]) {
        self.parts = parts
    }
    
    public var isEmpty: Bool {
        return parts.isEmpty
    }
    
    public var path: String {
        return parts.joined(separator: ".")
    }
    
    public var next: (part: String, remaining: KeyPath)? {
        guard !isEmpty else { return nil }
        var remainingParts = parts
        let part = remainingParts.removeFirst()
        return (part, KeyPath(parts: remainingParts))
    }
    
    //MARK: - Internal
    private(set) public var parts: [String]
}

extension KeyPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

public extension Dictionary where Key: StringProtocol {
    subscript<T>(keyPath keyPath: KeyPath) -> T? {
        get {
            switch keyPath.next {
            case let (part, path)? where path.isEmpty:
                return self[Key.init(cString: part)] as? T
                
            case let (part, path)?:
                switch self[Key.init(cString: part)] {
                case let dict as [Key: Any]:
                    return dict[keyPath: path]
                    
                default:
                    return nil
                }
                
            case nil:
                return nil
            }
        }
        
        set {
            switch keyPath.next {
            case let (part, path)? where path.isEmpty:
                self[Key.init(cString: part)] = newValue as? Value
                
            case let (part, path)?:
                let value = self[Key.init(cString: part)]
                switch value {
                case var dict as [Key: Any]:
                    dict[keyPath: path] = newValue
                    self[Key.init(cString: part)] = dict as? Value
                    
                default:
                    break
                }
                
            case nil:
                break
            }
        }
    }
}
