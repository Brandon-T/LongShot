//
//  Observer.swift
//  LongShot
//
//  Created by Brandon on 2018-05-20.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
}

private class DisposableReference: Disposable {
    private var disposer: ((DisposableReference) -> Void)?
    
    init(_ disposer: @escaping (DisposableReference) -> Void) {
        self.disposer = disposer
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        self.disposer?(self)
        self.disposer = nil
    }
}

public class Observable<T> {
    public typealias Observer = (_ newValue: T, _ oldValue: T?) -> Void
    private var subscribers = [(Observer, AnyObject)]()
    
    public init(_ value: T) {
        self.value = value
    }
    
    public var value: T {
        didSet {
            subscribers.forEach({
                $0.0(value, oldValue)
            })
        }
    }
    
    @discardableResult
    public func observe(_ observer: @escaping Observer) -> Disposable {
        let disposable = DisposableReference({ [weak self] in self?.removeObserver($0) })
        subscribers.append((observer, disposable))
        subscribers.forEach { $0.0(value, nil) }
        return disposable
    }
    
    public func removeObserver(_ object: AnyObject) {
        subscribers = subscribers.filter { $0.1 !== object }
    }
    
    public func removeAllObservers() {
        subscribers.removeAll()
    }
}

public struct ValueObservable<T> {
    public typealias Observer = (_ newValue: T, _ oldValue: T?) -> Void
    private var subscribers = [(Observer, AnyObject)]()
    
    public init(_ value: T) {
        self.value = value
    }
    
    public var value: T {
        didSet {
            subscribers.forEach({
                $0.0(value, oldValue)
            })
        }
    }
    
    @discardableResult
    public mutating func observe(_ observer: @escaping Observer) -> Disposable {
        let disposable = DisposableReference({ _ in })
        subscribers.append((observer, disposable))
        subscribers.forEach { $0.0(value, nil) }
        return disposable
    }
    
    public mutating func removeObserver(_ object: AnyObject) {
        subscribers = subscribers.filter { $0.1 !== object }
    }
    
    public mutating func removeAllObservers() {
        subscribers.removeAll()
    }
}
