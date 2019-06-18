//
//  DataStructures.swift
//  LongShot
//
//  Created by Soner Yuksel on 2019-06-18.
//  Copyright © 2019 XIO. All rights reserved.
//

import Foundation


/// Implementation of Stack Data Type in Swift
///
/// Stack is an abstract data type that serves as a collection of elements,
/// with two principal operations:
///
/// Push, which adds an element to the collection, and
/// Pop, which removes the most recently added element that was not yet removed.
///
/// The order in which elements come off a stack gives rise to its alternative name,
/// LIFO (last in, first out). Additionally,
/// Peek operation gives accsess to the top without modifying the stack

/// Usage:
///
/// var stack = Stack<Int>()
///
/// stack.push(1)
/// let element = stack.peek()
/// stack.pop()
/// let description = stack.description
///
/// let testArray = [1, 2, 3, 4]
/// stack = Stack(testArray)
///
/// let stackLiteral: Stack = [1, 2, 3]
/// stack == stackLiteral
///

struct Stack<Element: Equatable>: Equatable {
    
    /// Storage
    private var storage: [Element] = [Element]()
    
    /// Return if stack is Empty
    var isEmpty: Bool {
        return peek() == nil
    }
    
    /// Return number of elements in stack
    var count: Int {
        return storage.count
    }
    
    /// Initializers
    init() { }
    
    init(_ elements: [Element]) {
        storage = elements
    }
    
    /// Peek
    ///
    /// - Returns: The top element on the stack
    func peek() -> Element? {
        return storage.last
    }
    
    /// Push
    ///
    /// - Parameter element: Add element to the top of the stack
    mutating func push(_ element: Element) {
        storage.append(element)
    }
    
    /// Pop
    ///
    /// - Returns: Removes the top element and returns value
    @discardableResult
    mutating func pop() -> Element? {
        return storage.popLast()
    }
    
}

/// Protocol for getting outline description of the stack
extension Stack: CustomStringConvertible {
    
    var description: String {
        return storage
            .map { "\($0)"}
            .joined(separator: " ")
    }
    
}

/// Protocol allows to initialize Stack with Array
extension Stack: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...){
        storage = elements
    }
}

