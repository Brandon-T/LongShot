//
//  RequestToken.swift
//  PromiseClient
//
//  Created by Brandon Anthony on 2019-04-30.
//  Copyright © 2019 SO. All rights reserved.
//

import Foundation

/// A network request interceptor that handles session renewal, logging, and errors that happen during a request.
/// This class will handle automatic token renewal.
/// This class will handle logging a request's lifetime.
public class NetworkRequestInterceptor<Token>: ClientInterceptor {
    
    private let lock = NSRecursiveLock()
    private var isRenewingToken: Bool = false
    private var tasks = [DispatchWorkItem]()
    private let queue = DispatchQueue(label: "com.longshot.networking.client.queue", qos: DispatchQoS.userInitiated, attributes: .concurrent)
    private let renewSession: (() -> Request<Token>?)?
    public weak var client: Client?
    private let onTokenRenewed: ((_ client: Client?, _ token: Token?, _ error: Error?) -> Void)?
    
    //Initialize an interceptor that does NOT need session token handling..
    public init() {
        self.renewSession = nil
        self.onTokenRenewed = nil
    }
    
    //Initialize an interceptor that requires session token handling..
    public init(renewSession: @escaping @autoclosure () -> Request<Token>?, onTokenRenewed: @escaping (_ client: Client?, _ token: Token?, _ error: Error?) -> Void) {
        self.renewSession = renewSession
        self.onTokenRenewed = onTokenRenewed
    }
    
    public func willLaunchRequest<T>(_ request: URLRequest, for endpoint: Endpoint<T>) {
        //Request being launched.. Log it to the console..
    }
    
    public func requestSucceeded<T>(_ request: URLRequest, for endpoint: Endpoint<T>, response: URLResponse) {
        //Request succeeded.. Log it to the console..
    }
    
    public func requestFailed<T>(_ request: URLRequest, for endpoint: Endpoint<T>, error: Error, response: URLResponse?, completion: Any) {
        guard let completion = completion as? RequestCompletion<RequestSuccess<T>> else {
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            completion.reject(error)
            return
        }
        
        if self.renewSession == nil {
            completion.reject(error)
            return
        }
        
        //Handle token expiration..
        if response.statusCode == 401 {
            lock.lock()
            defer { lock.unlock() }
            
            //Check if we're already renewing..
            if !isRenewingToken {
                isRenewingToken = true
                
                queue.async {
                    self.renewSessionToken()
                }
            }
            
            //Add each request to the queue..
            var task: DispatchWorkItem!
            task = DispatchWorkItem {
                guard let task = task else { return }
                if !task.isCancelled {
                    self.client?.task(endpoint: endpoint)?.retryChain(completion)
                    return
                }
                
                completion.reject(error)
            }
            
            task.notify(queue: queue) { [weak self] in
                guard let self = self else { return }
                objc_sync_enter(self.tasks)
                defer { objc_sync_exit(self.tasks) }
                
                for index in 0..<self.tasks.count {
                    if self.tasks[index] === task {
                        self.tasks.remove(at: index)
                        break
                    }
                }
            }
            
            objc_sync_enter(self.tasks)
            self.tasks.append(task)
            objc_sync_exit(self.tasks)
            
            queue.async(execute: task)
        }
        else {
            //Request failed for other reasons.. Log it to the console..
            completion.reject(error)
        }
    }
    
    //Handles the renewing of the session token
    private func renewSessionToken() {
        self.renewSession?()?.then({ result in
            self.onSessionRenewalSucceeded(token: result.data)
        })
        .catch({ error in
            self.onSessionRenewalFailed(error: error)
        })
    }
    
    //Handles when the session token has successfully renewed
    private func onSessionRenewalSucceeded(token: Token) {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        self.onTokenRenewed?(self.client, token, nil)
        isRenewingToken = false
    }
    
    //Handles when the session token fails to be renewed
    private func onSessionRenewalFailed(error: Error) {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        //Suspend the queue..
        queue.suspend()
        
        //Remove all items..
        objc_sync_enter(self.tasks)
        self.tasks.forEach({ $0.cancel() })
        self.tasks.removeAll()
        objc_sync_exit(self.tasks)
        
        queue.resume()
        
        self.onTokenRenewed?(self.client, nil, error)
        isRenewingToken = false
    }
}
