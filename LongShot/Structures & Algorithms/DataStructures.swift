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
/// stack.push(1)                      push ->      -> pop
/// let element = stack.peek()                  |2|
/// stack.pop()                                 |3|
/// let description = stack.description         |8|
///                                             |4|
/// let testArray = [1, 2, 3, 4]                |1|
/// stack = Stack(testArray)                    |7|
///                                             ---
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


/// Implementation of Queue Data Type in Swift using Array as storage
///
/// Queue is a collection in which the entities in the collection are kept in order and the principal (or only)
///
/// Enqueue operation on the collection are the addition of entities to the rear terminal position
/// Dequeue removal of entities from the front terminal position
///
/// This makes the queue a First-In-First-Out (FIFO) data structure. In a FIFO data structure, the first element added
/// to the queue will be the first one to be removed.
///
/// New element is added, all elements that were added before have to be removed before the new element can be removed.
/// Often a peek or front operation is also entered, returning the value of the front element without dequeuing it.
/// A queue is an example of a linear data structure, or more abstractly a sequential collection.
///

/// Usage:
///
/// var queue: Queue<Int> = Queue([])
///
/// queue.enqueue(1)                 enqueue |   --------------------------  |-> dequeue
/// let element = queue.peek()               |-> 3 - 5 - 2 - 1 - 9 - 7 - 11  |
/// queue.dequeue()                              --------------------------
/// let description = queue.description
///
/// let testArray = [1, 2, 3, 4]
/// queue = Queue(testArray)
///
/// let queueLiteral: Queue = [1, 2, 3]
/// queue == queueLiteral
///

struct Queue<Element> {
    
    //Data Storage
    private var storage: [Element] = [Element]()
    
    //isEmpty
    var isEmpty: Bool {
        return storage.isEmpty
    }
    
    //Count
    var count: Int {
        return storage.count
    }
    
    //Initialize
    init() { }
    
    init(_ elements: [Element]) {
        storage = elements
    }
    
    //Peek
    func peek() -> Element? {
        return storage.first
    }
    
    //Enqueue
    mutating func enqueue(_ item: Element) {
        return storage.append(item)
    }
    
    //Dequeue
    @discardableResult
    mutating func dequeue() -> Element? {
        return isEmpty ? nil : storage.removeFirst()
    }
    
}

/// Protocol for getting outline description of the queue
extension Queue: CustomStringConvertible {
    
    var description: String {
        return storage
            .map { "\($0)"}
            .joined(separator: " ")
    }
    
}

/// Protocol allows to initialize Queue with Array
extension Queue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...){
        storage = elements
    }
}

