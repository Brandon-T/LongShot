//
//  Sequence+Algorithm.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension Sequence {
    func group<Key: Hashable>(predicate: (Iterator.Element) -> Key) -> [Key:[Iterator.Element]] {
        return Dictionary(grouping: self, by: predicate)
    }
    
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
    
    func orderedGroup<GroupingType: Hashable>(by key: (Iterator.Element) -> GroupingType) -> [[Iterator.Element]] {
        var groups: [GroupingType: [Iterator.Element]] = [:]
        forEach { element in
            let key = key(element)
            if case nil = groups[key]?.append(element) {
                groups[key] = [element]
            }
        }
        return groups.compactMap { $0.value }
    }
}

public extension Optional where Wrapped == String {
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let string):
            return string.isEmpty
        }
    }
}

#if compiler(<5)
public extension Optional where Wrapped == Collection {
    
    public var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let collection):
            return collection.isEmpty
        }
    }
}
#else
public extension Optional where Wrapped: Collection {
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let collection):
            return collection.isEmpty
        }
    }
}
#endif
