//
//  Promise.swift
//  LongShot
//
//  Created by Brandon on 2018-01-14.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation


/// An enum representing the internal state of a `Promise`.
///
/// - pending: The promise is currently pending (default state).
/// - fulfilled: The promise has been fulfilled successfully.
/// - rejected: The promise has encountered an error and cannot be fulfilled. It is rejected.
private enum PromiseState {
    case pending
    case fulfilled
    case rejected
}


/// A structure representing a single internal executable task of a `Promise`.
///
/// - queue: The queue to on which to execute the callbacks `onFulfill` and `onRejected`.
/// - fulfilled: The block to call when the task has been fulfilled successfully.
/// - rejected: The block to call when the task has encountered an error and cannot be fulfilled (rejected).
private struct PromiseTask<T> {
    let queue: DispatchQueue
    let onFulfill: (T) -> ()
    let onRejected: (Error) -> ()
}


/// A class used for synchronizing program execution in concurrent environments.
/// A promise executes a task asynchronously and can be chained as though tasks were executed synchronously.
///
///     let promise = Promise({ (resolve, reject) in
///         someAsyncNetworkTask({
///             if (success) {
///                 resolve(successfulValue)
///             }
///             else {
///                 reject(error)
///             }
///         })
///     })
///
///     promise.then {
///         //print(successfulValue)
///     }
///     .catch { (error) in
///         //print(error)
///     }
///
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
    
    
    /// Constructor to create a promise that will execute its tasks on the default queue.
    ///
    /// - Parameter task: A block that takes two functions `resolve` and `reject`. If the task succeeds, the caller must invoke `resolve` with the value of the successful task. Otherwise the caller must invoke `reject` with the reason why the task failed (an error).
    /// - Parameter resolve: A block that takes a parameter representing the type returned when this promise's task succeeds. If the task succeeds, the caller must invoke this block with the value of the successful task.
    /// - Parameter reject: A block that takes an `Error` parameter when this promise's task fails. If the task fails, the caller must invoke this block with an `Error` describing the reason why the task failed.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = Promise({ (resolve, reject) in
    ///         someAsyncNetworkTask({
    ///             if (success) {
    ///                 resolve(successfulValue)
    ///             }
    ///             else {
    ///                 reject(error)
    ///             }
    ///         })
    ///     })
    ///     ````
    ///
    public convenience init(_ task: @escaping ( _ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init(nil, task: task)
    }
    
    
    /// Constructor to create a promise that will execute its tasks on the specified queue.
    ///
    /// - Parameter on: A queue on which to execute the promise' tasks. This parameter is typically a backgrond queue.
    /// - Parameter task: A block that takes two functions `resolve` and `reject`. If the task succeeds, the caller must invoke `resolve` with the value of the successful task. Otherwise the caller must invoke `reject` with the reason why the task failed (an error).
    /// - Parameter resolve: A block that takes a parameter representing the type returned when this promise's task succeeds. If the task succeeds, the caller must invoke this block with the value of the successful task.
    /// - Parameter reject: A block that takes an `Error` parameter when this promise's task fails. If the task fails, the caller must invoke this block with an `Error` describing the reason why the task failed.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = Promise({ (resolve, reject) in
    ///         someAsyncNetworkTask({
    ///             if (success) {
    ///                 resolve(successfulValue)
    ///             }
    ///             else {
    ///                 reject(error)
    ///             }
    ///         })
    ///     })
    ///     ````
    ///
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
    
    
    /// Determines if the promise is still in `pending` state.
    public func isPending() -> Bool {
        return self.getValue() == nil && self.getError() == nil
    }
    
    
    /// Determines if the promise has been fulfilled.
    public func isFulfilled() -> Bool {
        return self.getValue() != nil
    }
    
    
    /// Determines if the promise has been rejected.
    public func isRejected() -> Bool {
        return self.getError() == nil
    }
    
    
    /// Gets the value of the promise. If the promise is still pending, returns nil.
    public func getValue() -> T? {
        return self.queue.sync { return self.value }
    }
    
    
    /// Gets the error of the promise if any. If the promise is still pending, returns nil.
    public func getError() -> Error? {
        return self.queue.sync { return self.error }
    }
    
    
    /// Fulfills the promise. Functions returning a promise must call this function with a valid result, to complete the contract with the callee. Call this function when the promise can be fulfilled with an expected valid.
    ///
    /// - Parameter result: The result of the promise (success value).
    public func fulfill(_ result: T) {
        if self.isPending() {
            self.queue.sync {
                self.value = result
                self.state = .fulfilled
            }
            self.doResolve()
        }
    }
    
    
    /// Rejects the promise. Functions returning a promise must call this function with a valid error, to complete the contract with the callee. Call this function when the promise cannot be fulfilled with an error.
    ///
    /// - Parameter error: The error describing what went wrong while fulfilling the promise (failure value).
    public func reject(_ error: Error) {
        if self.isPending() {
            self.queue.sync {
                self.error = error
                self.state = .rejected
            }
            self.doResolve()
        }
    }
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled.
    /// This callback is executed on the default task queue.
    ///
    /// - Parameter onFulfilled: A block to be called when the promise has been fulfilled.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns the original promise.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadImage(url: someUrl)
    ///     promise.then { (image) in
    ///
    ///         processImage(image)
    ///
    ///     }
    ///     ````
    ///
    @discardableResult
    public func then(_ onFulfilled: @escaping (T) -> Void) -> Promise<T> {
        return self.then(onFulfilled, { _ in })
    }
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled OR rejected.
    /// This callback is executed on the default task queue.
    ///
    /// - Parameters:
    ///   - onFulfilled: A block to be called when the promise has been fulfilled.
    ///   - onRejected: A block to be called when the promise has been rejected.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns the original promise.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadImage(url: someUrl)
    ///     promise.then({ image in
    ///
    ///         processImage(image)
    ///
    ///     }, { error in
    ///
    ///         logError("Something went wrong: \(error)")
    ///
    ///     })
    ///     ````
    ///
    @discardableResult //Made private - Use `catch` to catch rejections..
    private func then(_ onFulfilled: @escaping (T) -> Void, _ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        return self.then(nil, onFulfilled, onRejected)
    }
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled.
    /// This callback is executed on the specified queue.
    ///
    /// - Parameters:
    ///   - on: The queue on which to call the `onFulfilled` block.
    ///   - onFulfilled: A block to be called when the promise has been fulfilled.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns the original promise.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadImage(url: someUrl)
    ///     promise.then(DispatchQueue.main) { image in
    ///
    ///         self.imageView.image = image
    ///
    ///     }
    ///     ````
    ///
    @discardableResult
    public func then(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) -> Void) -> Promise<T> {
        return self.then(on, onFulfilled, { _ in })
    }
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled OR rejected.
    /// This callback is executed on the specified queue.
    ///
    /// - Parameters:
    ///   - on: The queue on which to call the `onFulfilled` or `onRejected` blocks.
    ///   - onFulfilled: A block to be called when the promise has been fulfilled.
    ///   - onRejected: A block to be called when the promise has been rejected.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns the original promise.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadImage(url: someUrl)
    ///     promise.then(DispatchQueue.main, { image in
    ///
    ///         self.imageView.image = image
    ///
    ///     }, { error in
    ///
    ///         self.imageView.image = placeHolder
    ///         logError("Something went wrong: \(error)")
    ///
    ///     })
    ///     ````
    ///
    @discardableResult //Made private - Use `catch` to catch rejections..
    public func then(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) -> Void, _ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        self.queue.async {
            let queue = on ?? DispatchQueue.main
            self.tasks.append(PromiseTask<T>(queue: queue, onFulfill: onFulfilled, onRejected: onRejected))
        }
        self.doResolve()
        return self
    }
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled.
    /// This callback is executed on the default task queue.
    ///
    /// - Parameter onFulfilled: A block to be called when the promise has been fulfilled. This block returns a different `Value` type than the original promise.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns a new promise of specified type.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadProfile(url: someUrl)
    ///     promise.then { (profile) in
    ///
    ///         print(profile.firstName)
    ///
    ///         return profile.image
    ///
    ///     }
    ///     .then { profileImage in
    ///
    ///         self.imageView.image = profileImage
    ///
    ///     }
    ///     ````
    ///
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
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled.
    /// This callback is executed on the default task queue.
    ///
    /// - Parameter onFulfilled: A block to be called when the promise has been fulfilled. This block returns another `Promise`.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns a new promise of specified type.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadProfile(url: someUrl)
    ///     promise.then { (profile) in
    ///
    ///         print(profile.firstName)
    ///
    ///         return NetworkManager.downloadImage(profile.imageUrl)
    ///
    ///     }
    ///     .then { profileImage in
    ///
    ///         self.imageView.image = profileImage
    ///
    ///     }
    ///     ````
    ///
    @discardableResult
    public func then<Value>(_ onFulfilled: @escaping (T) throws -> Promise<Value>) -> Promise<Value> {
        return self.then(nil, onFulfilled)
    }
    
    
    /// A chainable callback function to be called when the promise has been successfully fulfilled.
    /// This callback is executed on the specified queue.
    ///
    /// - Parameters:
    ///   - on: The queue on which to call the `onFulfilled` or `onRejected` blocks.
    ///   - onFulfilled: A block to be called when the promise has been fulfilled. This block returns another `Promise`.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns a new promise of specified type.
    ///
    /// Example:
    ///
    ///     ````
    ///     let promise = NetworkManager.downloadProfile(url: someUrl)
    ///     promise.then(DispatchQueue.main, { (profile) in
    ///
    ///         print(profile.firstName)
    ///
    ///         return NetworkManager.downloadImage(profile.imageUrl)
    ///
    ///     })
    ///     .then { profileImage in
    ///
    ///         self.imageView.image = profileImage
    ///
    ///     }
    ///     ````
    ///
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
    
    
    /// A chainable callback function to be called when the promise has been rejected.
    /// This callback is executed on the default task queue.
    ///
    /// - Parameter onRejected:  A block to be called when the promise has been rejected.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns the original promise.
    @discardableResult
    public func `catch`(_ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        return self.`catch`(nil, onRejected)
    }
    
    
    /// A chainable callback function to be called when the promise has been rejected.
    ///
    /// - Parameters:
    ///   - on: The queue on which to call the `onRejected` block.
    ///   - onRejected: A block to be called when the promise has been rejected.
    /// - Returns: A promise that can be used to chain more completion handling blocks. Returns the original promise.
    @discardableResult
    public func `catch`(_ on: DispatchQueue? = nil, _ onRejected: @escaping (Error) -> Void) -> Promise<T> {
        return self.then(on, { _ in }, onRejected)
    }
    
    
    /// The internal resolver  that resolves whether a task has been fulfilled, rejected or is still pending.
    /// Executes the `onFulfilled` and `onRejected` blocks on their task queues.
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
