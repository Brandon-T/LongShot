//
//  Request.swift
//  Services
//
//  Created by Brandon on 2018-12-09.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

/// A request object that contains the original endpoint that was requested (along with the entire request itself)
/// And it contains a future which is a read-only promise to be used for event handling for each request.
/// The advantage is that it avoids callback hell/nesting and also allows us to decide right at the point of the callee which queue to use if we need any custom queueing..
/// If for some odd reason we need the request to be completed synchronously as well, we can do so safely with the timeout function..
public struct Request<T> {
    public typealias ResponseType = (data: T, response: URLResponse)
    
    private (set) public var endpoint: Endpoint<T>
    private var task: URLSessionDataTask!
    private var future: Future<ResponseType>
    
    init(_ endpoint: Endpoint<T>, task: URLSessionDataTask!, promise: Promise<ResponseType>) {
        self.endpoint = endpoint
        self.task = task
        self.future = Future<ResponseType>(promise)
    }
    
    private init(_ endpoint: Endpoint<T>, task: URLSessionDataTask, future: Future<ResponseType>) {
        self.endpoint = endpoint
        self.task = task
        self.future = future
    }
    
    public func retry() {
        //TODO: Implement request retrying..
    }
    
    public func cancel() {
        self.task.cancel()
    }
    
    // MARK: - Event Handlers
    
    public func get() throws -> ResponseType? {
        return try self.future.get()
    }
    
    public func wait(timeout: DispatchTime = DispatchTime.distantFuture) throws -> ResponseType? {
        return try self.future.wait(timeout: timeout)
    }
    
    @discardableResult
    public func onSuccess(_ onSuccess: @escaping (_ value: ResponseType) -> Void) -> Request {
        self.future.onSuccess(nil, onSuccess)
        return self
    }
    
    @discardableResult
    public func onError(_ onError: @escaping (_ value: Error) -> Void) -> Request {
        self.future.onError(onError)
        return self
    }
    
    @discardableResult
    public func onSuccess(_ on: DispatchQueue? = nil, _ onSuccess: @escaping (_ value: ResponseType) -> Void) -> Request {
        self.future.onSuccess(on, onSuccess)
        return self
    }
    
    @discardableResult
    public func onError(_ on: DispatchQueue? = nil, _ onError: @escaping (_ value: Error) -> Void) -> Request {
        self.future.onError(on, onError)
        return self
    }
    
    @discardableResult
    public func onCompletion(_ onSuccess: @escaping (_ value: ResponseType?) -> Void, _ onError: @escaping (_ error: Error) -> Void) -> Request {
        self.future.onCompletion(onSuccess, onError)
        return self
    }
    
    @discardableResult
    public func onCompletion(_ on: DispatchQueue? = nil, _ onSuccess: @escaping (_ value: ResponseType?) -> Void, _ onError: @escaping (_ error: Error) -> Void) -> Request {
        self.future.onCompletion(on, onSuccess, onError)
        return self
    }
}
