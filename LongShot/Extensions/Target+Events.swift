//
//  Target+Events.swift
//  LongShot
//
//  Created by Brandon on 2018-01-06.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public protocol RemovableTarget {
    func remove();
}

internal final class EventTarget<T> : RemovableTarget where T : NSObject {
    private (set) weak var object: T?
    private var runnable: ((T) -> Void)?
    private var addListener: (() -> Void)?
    private var removeListener: (() -> Void)?
    
    private init(_ object: T, runnable: @escaping (T) -> Void) {
        self.object = object
        self.runnable = runnable
        self.retain()
    }
    
    private init(_ initializer: (EventTarget, Selector) -> T, runnable: @escaping (T) -> Void) {
        self.object = initializer(self, #selector(EventTarget.run(_:)))
        self.runnable = runnable
        self.retain()
    }
    
    @objc
    private func run(_ object: NSObject) {
        self.runnable?(object as! T)
    }
    
    func remove() {
        self.removeListener?()
        self.object?.removeObject(key: self.address())
    }
    
    private func retain() {
        self.object?.setObject(object: self, key: self.address(), policy: .OBJC_ASSOCIATION_RETAIN)
    }
    
    private func address() -> String {
        return String(format:"%p", Unmanaged.passUnretained(self).toOpaque().hashValue)
    }
}


internal extension EventTarget where T : UIControl {
    convenience init(_ object: T, event: UIControl.Event, runnable: @escaping (T) -> Void) {
        self.init({ (target, selector) -> T in
            object.addTarget(target, action: selector, for: event)
            return object
        }, runnable: runnable)
        
        self.addListener = { [weak self] in
            guard let self = self else { return }
            self.object?.addTarget(self, action: #selector(EventTarget.run(_:)), for: event)
        }
        
        self.removeListener = { [weak self] in
            guard let self = self else { return }
            self.object?.removeTarget(self, action: #selector(EventTarget.run(_:)), for: event)
        }
    }
}

internal extension EventTarget where T : UIGestureRecognizer {
    convenience init(_ object: T, runnable: @escaping (T) -> Void) {
        self.init({ (target, selector) -> T in
            object.addTarget(target, action: selector)
            return object
        }, runnable: runnable)

        self.addListener = { [weak self] in
            guard let self = self else { return }
            self.object?.addTarget(self, action: #selector(EventTarget.run(_:)))
        }

        self.removeListener = { [weak self]() in
            guard let self = self else { return }
            self.object?.removeTarget(self, action: #selector(EventTarget.run(_:)))
        }
    }
}

internal extension EventTarget where T : UIBarButtonItem {
    convenience init(_ object: T, runnable: @escaping (T) -> Void) {
        self.init({ (target, selector) -> T in
            object.target = target
            object.action = selector
            return object
        }, runnable: runnable)
        
        self.addListener = { [weak self] in
            guard let self = self else { return }
            self.object?.target = self
            self.object?.action = #selector(EventTarget.run(_:))
        }
        
        self.removeListener = { [weak self] in
            guard let self = self else { return }
            self.object?.target = nil
            self.object?.action = nil
        }
    }
}

