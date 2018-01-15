//
//  Promise.swift
//  LongShot
//
//  Created by Brandon on 2018-01-14.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

private enum PromiseState {
    case pending
    case fulfilled
    case rejected
}

private struct PromiseTask<T> {
    let queue: DispatchQueue
    let onFulfill: (T) -> ()
    let onRejected: (Error) -> ()
}

public class Promise<T> {
    private var state: PromiseState = .pending
    private var value: T? = nil
    private var error: Error? = nil
    private let queue: DispatchQueue
    private lazy var tasks: [PromiseTask<T>] = {
        return [PromiseTask<T>]()
    }()
    
    private init() {
        self.queue = DispatchQueue(label: "com.long.shot.promise.queue", qos: .default)
    }
    
    public convenience init(_ task: @escaping ( _ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init(nil, task: task)
    }
    
    public convenience init(_ on: DispatchQueue? = nil, task: @escaping (_ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init()
        let queue = on ?? DispatchQueue.global(qos: .default)
        queue.async {
            do {
                try task(self.fulfill, self.reject)
            }
            catch let error {
                self.reject(error)
            }
        }
    }
    
    public func isPending() -> Bool {
        return self.getValue() == nil && self.getError() == nil
    }
    
    public func isFulfilled() -> Bool {
        return self.getValue() != nil
    }
    
    public func isRejected() -> Bool {
        return self.getError() == nil
    }
    
    public func getValue() -> T? {
        return self.queue.sync { return self.value }
    }
    
    public func getError() -> Error? {
        return self.queue.sync { return self.error }
    }
    
    public func fulfill(_ result: T) {
        if self.isPending() {
            self.queue.sync {
                self.value = result
                self.state = .fulfilled
            }
            self.doResolve()
        }
    }
    
    public func reject(_ error: Error) {
        if self.isPending() {
            self.queue.sync {
                self.error = error
                self.state = .rejected
            }
            self.doResolve()
        }
    }
    
    //Regular Then-able's with Void return type
    @discardableResult
    public func then(_ onFulfilled: @escaping (T) -> Void) -> Promise<T> {
        return self.then(onFulfilled, { _ in })
    }
    
    @discardableResult
    public func then(_ onFulfilled: @escaping (T) -> Void, _ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        return self.then(nil, onFulfilled, onRejected)
    }
    
    @discardableResult
    public func then(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) -> Void) -> Promise<T> {
        return self.then(on, onFulfilled, { _ in })
    }
    
    @discardableResult
    public func then(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) -> Void, _ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        self.queue.async {
            let queue = on ?? DispatchQueue.main
            self.tasks.append(PromiseTask<T>(queue: queue, onFulfill: onFulfilled, onRejected: onRejected))
        }
        self.doResolve()
        return self
    }
    
    //Coercive Then-able's (allow to return a different type of `value` for then block)
    @discardableResult
    public func then<Value>(_ onFulfilled: @escaping (T) throws -> Value) -> Promise<Value> {
        return self.then({ (value) -> Promise<Value> in
            do {
                let promise = Promise<Value>()
                promise.state = .fulfilled
                promise.value = try onFulfilled(value)
                return promise
            } catch let error {
                let promise = Promise<Value>()
                promise.state = .rejected
                promise.error = error
                return promise
            }
        })
    }
    
    //Coercive Then-able's (allow to return a different type of `promise` for then block)
    @discardableResult
    public func then<Value>(_ onFulfilled: @escaping (T) throws -> Promise<Value>) -> Promise<Value> {
        return self.then(nil, onFulfilled)
    }
    
    //Coercive Then-able's (allow to return a different type of `promise` for then block)
    @discardableResult
    public func then<Value>(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) throws -> Promise<Value>) -> Promise<Value> {
        return Promise<Value>({ [weak self] fulfill, reject in
            let queue = on ?? DispatchQueue.main
            self?.tasks.append(PromiseTask<T>(queue: queue, onFulfill: { (value) in
                do {
                    try onFulfilled(value).then(fulfill, reject)
                }
                catch let error {
                    reject(error)
                }
            }, onRejected: { (error) in
                reject(error)
            }))
        })
    }
    
    @discardableResult
    public func `catch`(_ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        return self.`catch`(nil, onRejected)
    }
    
    @discardableResult
    public func `catch`(_ on: DispatchQueue? = nil, _ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        return self.then(on, { _ in }, onRejected)
    }
    
    private func doResolve() {
        self.queue.async {
            if self.state != .pending {
                self.tasks.forEach({ [unowned self](task) in
                    if self.state == .fulfilled {
                        if let value = self.value {
                            task.queue.async {
                                task.onFulfill(value)
                            }
                        }
                    }
                    else if self.state == .rejected {
                        if let error = self.error {
                            task.queue.async {
                                task.onRejected(error)
                            }
                        }
                    }
                })
                self.tasks = []
            }
        }
    }
}
