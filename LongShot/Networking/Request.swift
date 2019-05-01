//
//  Request.swift
//  Services
//
//  Created by Brandon on 2018-12-09.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

#if canImport(Alamofire)
import Alamofire
#endif

/// The base class of each request that contains a promise for execution of a request sequentially
public class RequestBase<T> {
    fileprivate let promise: RequestPromise<RequestSuccess<T>>
    
    fileprivate init(_ on: DispatchQueue? = nil, task: @escaping (_ resolve: @escaping (RequestSuccess<T>) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        
        self.promise = RequestPromise<RequestSuccess<T>>(on, task: task)
    }
}

/// A request object that contains the original endpoint that was requested (along with the entire request itself)
/// And it contains a future which is a read-only promise to be used for event handling for each request.
/// The advantage is that it avoids callback hell/nesting and also allows us to decide right at the point of the callee which queue to use if we need any custom queueing..
/// If for some odd reason we need the request to be completed synchronously as well, we can do so safely with the timeout function..
public class Request<T>: RequestBase<T> {
    public typealias ResponseType = (data: T, response: URLResponse)
    
    private let lock = NSRecursiveLock()
    private (set) public var endpoint: Endpoint<T>
    private var task: URLSessionTask?
    private weak var sessionManager: Client?
    private var retryCount = 0
    private lazy var tasks: [RequestTask] = {
        return [RequestTask]()
    }()
    
    #if canImport(Alamofire)
    /// Creates a request
    /// Use this initializer when the request should be executed immediately
    internal init(_ session: Client, endpoint: Endpoint<T>, task: DataRequest, promise: RequestCompletion<RequestSuccess<T>>) {
        self.sessionManager = session
        self.endpoint = endpoint
        self.task = task.task
        
        super.init(nil, task: { resolve, reject in
            promise.resolve = resolve
            promise.reject = reject
        })
        task.resume()
    }
    
    /// Creates a request
    /// Use this initializer when the requesst should NOT execute immediately and a client is unavailable
    private init(_ endpoint: Endpoint<T>, task: URLSessionTask?, promise: RequestCompletion<RequestSuccess<T>>) {
        self.sessionManager = nil
        self.endpoint = endpoint
        self.task = task
        
        super.init(nil, task: { resolve, reject in
            promise.resolve = resolve
            promise.reject = reject
        })
    }
    #else
    /// Creates a request
    /// Use this initializer when the request should be executed immediately
    internal init(_ session: Client, endpoint: Endpoint<T>, task: URLSessionTask, promise: RequestCompletion<RequestSuccess<T>>) {
        self.sessionManager = session
        self.endpoint = endpoint
        self.task = task
        
        super.init(nil, task: { resolve, reject in
            promise.resolve = resolve
            promise.reject = reject
        })
        task.resume()
    }
    
    /// Creates a request
    /// Use this initializer when the requesst should NOT execute immediately and a client is unavailable
    private init(_ endpoint: Endpoint<T>, task: URLSessionTask?, promise: RequestCompletion<RequestSuccess<T>>) {
        self.sessionManager = nil
        self.endpoint = endpoint
        self.task = task
        
        super.init(nil, task: { resolve, reject in
            promise.resolve = resolve
            promise.reject = reject
        })
    }
    #endif
    
    // MARK: - Private
    
    /// Maps a request's response to a response type structure
    private static func mapResponse(_ info: RequestSuccess<T>) -> ResponseType {
        return (info.data, info.response)
    }
    
    /// Used for session renewal to re-execute a request using the internal promise chain
    /// Calls the completion block when the request has been executed/retried
    @discardableResult
    internal func retryChain(_ completion: RequestCompletion<RequestSuccess<T>>) -> Request {
        self.promise.then {
            completion.resolve($0)
        }.catch {
            completion.reject($0)
        }
        return self
    }
    
    // MARK: - Public
    
    /// Retry a request for a max amount of times (count)
    @discardableResult
    public func retry(_ count: Int) -> Request {
        func retryRequest(count: Int, completion: RequestCompletion<RequestSuccess<T>>) {
            self.promise.then({
                completion.resolve($0)
            }).catch({
                if count == 1 {
                    completion.reject($0)
                }
                else {
                    self.sessionManager?.task(endpoint: self.endpoint)?.promise.then {
                        completion.resolve($0)
                        }.catch { _ in
                            retryRequest(count: count - 1, completion: completion)
                    }
                }
            })
        }
        
        let promise = RequestCompletion<RequestSuccess<T>>({_ in}, {_ in})
        let request = Request<T>(self.endpoint, task: self.task, promise: promise)
        request.sessionManager = self.sessionManager
        retryRequest(count: count, completion: promise)
        return request
    }
    
    /// Cancels a request's execution
    @discardableResult
    public func cancel() -> Request {
        self.task?.cancel()
        return self
    }
    
    // MARK: - Event Handlers
    
    /// Waits for a request to complete and returns its response synchronously
    /// Waits for a single CPU cycle and returns immediately
    /// Be-careful running synchronous requests on main as it may block until complete!
    public func get() throws -> ResponseType? {
        return try self.promise.get().map({ Request<T>.mapResponse($0) })
    }

    /// Waits for a specific amount of time for a request to complete and returns its response synchronously
    /// Be-careful running synchronous requests on main as it may block until complete!
    public func wait(timeout: DispatchTime = DispatchTime.distantFuture) throws -> ResponseType? {
        return try self.promise.wait(timeout: timeout).map({ Request<T>.mapResponse($0) })
    }
    
    /// Used to chain a successful request on the main queue and handle its success response
    @discardableResult
    public func then(_ onSuccess: @escaping (_ value: ResponseType) -> Void) -> Request {
        self.lock.lock()
        tasks.append(RequestTask(queue: .main, resolve: onSuccess, reject: { _ in }))
        self.promise.then({ onSuccess(Request<T>.mapResponse($0)) })
        self.lock.unlock()
        return self
    }
    
    /// Used to chain a failed request on the main queue and handle its error response
    @discardableResult
    public func `catch`(_ onError: @escaping (_ value: Error) -> Void) -> Request {
        self.lock.lock()
        tasks.append(RequestTask(queue: .main, resolve: { _ in }, reject: onError))
        self.promise.catch(onError)
        self.lock.unlock()
        return self
    }
    
    /// Used to chain a successful request on a specific `DispatchQueue` and handle its success response
    @discardableResult
    public func then(_ on: DispatchQueue? = nil, _ onSuccess: @escaping (_ value: ResponseType) -> Void) -> Request {
        self.lock.lock()
        tasks.append(RequestTask(queue: on ?? .main, resolve: onSuccess, reject: { _ in }))
        self.promise.then(on, { onSuccess(Request<T>.mapResponse($0)) })
        self.lock.unlock()
        return self
    }
    
    /// Used to chain a failed request on a specific `DispatchQueue` and handle its error response
    @discardableResult
    public func `catch`(_ on: DispatchQueue? = nil, _ onError: @escaping (_ value: Error) -> Void) -> Request {
        self.lock.lock()
        tasks.append(RequestTask(queue: on ?? .main, resolve: { _ in }, reject: onError))
        self.promise.catch(on, onError)
        self.lock.unlock()
        return self
    }
    
    //A structure that holds only enough information to allow retrying of the request..
    private struct RequestTask {
        let queue: DispatchQueue
        let resolve: (_ value: ResponseType) -> Void
        let reject: (_ value: Error) -> Void
    }
}


// MARK: - Private

/// A successful request's internal response
internal struct RequestSuccess<T> {
    /// The serialized model of the server response
    let data: T
    
    /// The raw response data returned from the server
    let rawData: Data
    
    /// The server's response
    let response: URLResponse
}

/// A failed request's internal error
internal struct RequestFailure: Error {
    /// The error returned from the server
    let error: Error
    
    /// The raw response data returned from the server
    let rawData: Data?
    
    /// The server's response
    let response: URLResponse?
}

/// An internal request completion that represents a promise's resolve and reject interface
internal class RequestCompletion<T> {
    /// Resolve the request - Marks a request successful
    var resolve: (T) -> Void
    
    /// Reject the request - Marks a request as failed
    var reject: (Error) -> Void
    
    /// Creates a RequestCompletion
    init(_ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) {
        self.resolve = resolve
        self.reject = reject
    }
}

/// A promise implementation with all fields `private` and `fileprivate` in order to make it act like a `Future` (A future is a read-only promise)
/// This class it taken from https://github.com/Brandon-T/LongShot and modified to include the Future implementation as well
private class RequestPromise<T> {
    private var state: RequestPromiseState = .pending
    private var value: T? = nil
    private var error: Error? = nil
    private let queue: DispatchQueue
    private lazy var tasks: [RequestPromiseTask<T>] = {
        return [RequestPromiseTask<T>]()
    }()
    
    /// Initializes the promise queue
    private init() {
        self.queue = DispatchQueue(label: "com.long.shot.promise.queue", qos: .default)
    }
    
    /// Initializes the promise with a task
    fileprivate convenience init(_ task: @escaping ( _ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init(nil, task: task)
    }
    
    /// Initializes the promise with a task on a specific queue
    fileprivate init(_ on: DispatchQueue? = nil, task: @escaping (_ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.queue = DispatchQueue(label: "com.long.shot.promise.queue", qos: .default)
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
    
    /// Synchronously returns the value
    fileprivate func get() throws -> T? {
        return try self.wait(timeout: .now())
    }
    
    /// Waits a specified amount of time for the promise to resolve and returns the response synchronously
    fileprivate func wait(timeout: DispatchTime = DispatchTime.distantFuture) throws -> T? {
        if self.isPending() {
            let lock = DispatchSemaphore(value: 0)
            self.then(.global(qos: .userInitiated), { [weak self](value) in
                self?.queue.sync { self?.value = value }
                lock.signal()
                }, { [weak self](error) in
                    self?.queue.sync { self?.error = error }
                    lock.signal()
            })
            
            if lock.wait(timeout: timeout) == .success {
                return self.queue.sync { self.value }
            }
        }
        
        if let error = self.queue.sync(execute: { return self.error }) {
            throw error
        }
        return self.queue.sync { return self.value }
    }
    
    /// Determines if the promise is pending
    fileprivate func isPending() -> Bool {
        return self.getValue() == nil && self.getError() == nil
    }
    
    /// Determines if the promise is fulfilled
    fileprivate func isFulfilled() -> Bool {
        return self.getValue() != nil
    }
    
    /// Determines if the promise is rejected
    fileprivate func isRejected() -> Bool {
        return self.getError() == nil
    }
    
    /// Returns the promise's value
    fileprivate func getValue() -> T? {
        return self.queue.sync { return self.value }
    }
    
    /// Returns the promise's error
    fileprivate func getError() -> Error? {
        return self.queue.sync { return self.error }
    }
    
    /// Fulfills the promise
    fileprivate func fulfill(_ result: T) {
        if self.isPending() {
            self.queue.sync {
                self.value = result
                self.state = .fulfilled
            }
            self.doResolve()
        }
    }
    
    /// Rejects the promise
    fileprivate func reject(_ error: Error) {
        if self.isPending() {
            self.queue.sync {
                self.error = error
                self.state = .rejected
            }
            self.doResolve()
        }
    }
    
    /// Chains the promise when it is successful, catching only resolution
    @discardableResult
    fileprivate func then(_ onFulfilled: @escaping (T) -> Void) -> RequestPromise<T> {
        return self.then(onFulfilled, { _ in })
    }
    
    /// Chains the promise when it is successful, catching resolution
    /// Chains the promise when it has failed, catching rejection
    @discardableResult //Made private - Use `catch` to catch rejections..
    private func then(_ onFulfilled: @escaping (T) -> Void, _ onRejected: @escaping (Error) -> Void) -> RequestPromise<T> {
        return self.then(nil, onFulfilled, onRejected)
    }
    
    /// Chains the promise on a specified queue when it is successful, catching only resolution
    @discardableResult
    fileprivate func then(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) -> Void) -> RequestPromise<T> {
        return self.then(on, onFulfilled, { _ in })
    }
    
    /// Chains the promise on a specified queue when it is successful, catching resolution
    /// Chains the promise on a specified queue, when it has failed, catching rejection
    @discardableResult //Made private - Use `catch` to catch rejections..
    fileprivate func then(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) -> Void, _ onRejected: @escaping (Error) -> Void) -> RequestPromise<T> {
        self.queue.async {
            let queue = on ?? DispatchQueue.main
            self.tasks.append(RequestPromiseTask<T>(queue: queue, onFulfill: onFulfilled, onRejected: onRejected))
        }
        self.doResolve()
        return self
    }
    
    /// Chains the promise when it is successful, catching only resolution, and returning a different value
    @discardableResult
    fileprivate func then<Value>(_ onFulfilled: @escaping (T) throws -> Value) -> RequestPromise<Value> {
        return self.then({ (value) -> RequestPromise<Value> in
            do {
                let promise = RequestPromise<Value>()
                promise.state = .fulfilled
                promise.value = try onFulfilled(value)
                return promise
            } catch let error {
                let promise = RequestPromise<Value>()
                promise.state = .rejected
                promise.error = error
                return promise
            }
        })
    }
    
    /// Chains the promise when it is successful, catching only resolution, and returning a different promise
    @discardableResult
    fileprivate func then<Value>(_ onFulfilled: @escaping (T) throws -> RequestPromise<Value>) -> RequestPromise<Value> {
        return self.then(nil, onFulfilled)
    }
    
    /// Chains the promise when it is successful on a specified queue, catching only resolution, and returning a different promise
    @discardableResult
    fileprivate func then<Value>(_ on: DispatchQueue? = nil, _ onFulfilled: @escaping (T) throws -> RequestPromise<Value>) -> RequestPromise<Value> {
        return RequestPromise<Value>({ [weak self] fulfill, reject in
            let queue = on ?? DispatchQueue.main
            self?.tasks.append(RequestPromiseTask<T>(queue: queue, onFulfill: { (value) in
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
    
    /// Chains the promise when it fails, catching only rejection
    @discardableResult
    fileprivate func `catch`(_ onRejected: @escaping (Error) -> Void) -> RequestPromise<T> {
        return self.`catch`(nil, onRejected)
    }
    
    /// Chains the promise on a specified queue when it fails, catching only rejection
    @discardableResult
    fileprivate func `catch`(_ on: DispatchQueue? = nil, _ onRejected: @escaping (Error) -> Void) -> RequestPromise<T> {
        return self.then(on, { _ in }, onRejected)
    }
    
    /// Handles resolving the promise
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
    
    
    private enum RequestPromiseState {
        case pending
        case fulfilled
        case rejected
    }
    
    private struct RequestPromiseTask<T> {
        let queue: DispatchQueue
        let onFulfill: (T) -> ()
        let onRejected: (Error) -> ()
    }
}
