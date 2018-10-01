//
//  TaskQueue.swift
//  LongShot
//
//  Created by Brandon on 2018-09-30.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public class TaskQueue {
    private let queue = DispatchQueue(label: "com.longshot.task.queue", qos: .userInitiated, attributes: .concurrent)
    private let completionQueue = DispatchQueue(label: "com.longshot.task.completion.queue", qos: .userInitiated)
    
    private let lock = NSLock()
    private var isSuspended: Bool = false
    private var tasks = [DispatchWorkItem]()
    private let taskLock = NSLock()
    
    public func resume() {
        lock.lock(); defer { lock.unlock() }
        guard isSuspended else { return }
        isSuspended = false
        queue.resume()
    }
    
    public func pause() {
        lock.lock(); defer { lock.unlock() }
        guard !isSuspended else { return }
        isSuspended = true
        queue.suspend()
    }
    
    public func cancel() {
        lock.lock(); defer { lock.unlock() }
        if !isSuspended {
            isSuspended = true
            queue.suspend()
        }
        
        Mutex.synchronized(lock: tasks) {
            self.tasks.forEach({ $0.cancel() })
            self.tasks.removeAll()
        }
        
        queue.resume()
        isSuspended = false
    }
    
    public func enqueue(_ runnable: @escaping @convention(block) () -> Void) {
        var task: DispatchWorkItem?
        task = DispatchWorkItem {
            guard let task = task else { return }
            guard !task.isCancelled else { return }
            runnable()
        }
        
        guard let job = task else { return }
        job.notify(queue: completionQueue) { [weak self] in
            guard let self = self else { return }
            
            Mutex.synchronized(lock: self.tasks, action: {
                self.tasks.remove(job)
            })
        }
        
        Mutex.synchronized(lock: self.tasks) {
            self.tasks.append(job)
        }
        
        queue.async(execute: job)
    }
}
