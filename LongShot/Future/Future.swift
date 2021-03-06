//
//  Future.swift
//  LongShot
//
//  Created by Brandon on 2018-01-14.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

/// A read-only view of a promise
public class Future<T> {
    private var promise: Promise<T>
    private var value: T?
    private var error: Error?
    private var lock: DispatchSemaphore?
    private let queue: DispatchQueue
    
    public init(_ promise: Promise<T>) {
        self.promise = promise
        self.queue = DispatchQueue(label: "com.long.shot.future.queue", qos: .default)
    }
    
    public func get() throws -> T? {
        return try self.wait(timeout: .now())
    }
    
    public func wait(timeout: DispatchTime = DispatchTime.distantFuture) throws -> T? {
        if self.promise.isPending() {
            if self.lock == nil {
                self.lock = DispatchSemaphore(value: 0)
                
                self.promise.then(.global(qos: .userInitiated), { [weak self](value) in
                    self?.queue.sync { self?.value = value }
                    self?.lock?.signal()
                    }, { [weak self](error) in
                        self?.queue.sync { self?.error = error }
                        self?.lock?.signal()
                })
                
                if self.lock?.wait(timeout: timeout) == .success {
                    self.lock = nil
                }
            }
            else {
                if self.lock?.wait(timeout: timeout) == .success {
                    self.lock = nil
                }
            }
        }
        
        if let error = self.queue.sync(execute: { return self.error }) {
            throw error
        }
        return self.queue.sync { return self.value }
    }
    
    @discardableResult
    public func onSuccess(_ onSuccess: @escaping (_ value: T) -> Void) -> Self {
        return self.onSuccess(nil, onSuccess)
    }
    
    @discardableResult
    public func onError(_ onError: @escaping (_ value: Error) -> Void) -> Self {
        return self.onError(nil, onError)
    }
    
    @discardableResult
    public func onSuccess(_ on: DispatchQueue? = nil, _ onSuccess: @escaping (_ value: T) -> Void) -> Self {
        self.promise.then(on, { [weak self](value) in
            self?.queue.sync { self?.value = value }
            onSuccess(value)
        })
        return self
    }
    
    @discardableResult
    public func onError(_ on: DispatchQueue? = nil, _ onError: @escaping (_ value: Error) -> Void) -> Self {
        self.promise.catch(on) { [weak self] error in
            self?.queue.sync { self?.error = error }
            onError(error)
        }
        return self
    }
    
    @discardableResult
    public func onCompletion(_ onSuccess: @escaping (_ value: T?) -> Void, _ onError: @escaping (_ error: Error) -> Void) -> Self {
        return self.onCompletion(nil, onSuccess, onError)
    }
    
    @discardableResult
    public func onCompletion(_ on: DispatchQueue? = nil, _ onSuccess: @escaping (_ value: T?) -> Void, _ onError: @escaping (_ error: Error) -> Void) -> Self {
        
        if self.promise.isPending() {
            self.promise.then(on, { [weak self](value) in
                self?.queue.sync { self?.value = value }
                onSuccess(value)
            }) { [weak self](error) in
                self?.queue.sync { self?.error = error }
                onError(error)
            }
        }
        else {
            if let error = self.queue.sync(execute: { return self.error }) {
                onError(error)
            }
            else {
                onSuccess(self.queue.sync { return self.value })
            }
        }
        return self
    }
}
