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
        self.addListener?()
    }
    
    private init(_ initializer: (EventTarget, Selector) -> T, runnable: @escaping (T) -> Void) {
        self.object = initializer(self, #selector(EventTarget.run(_:)))
        self.runnable = runnable
        self.retain()
        self.addListener?()
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
    convenience init(_ object: T, event: UIControlEvents, runnable: @escaping (T) -> Void) {
        self.init(object, runnable: runnable)
        
        self.addListener = { [weak self]() in
            if let strongSelf = self {
                strongSelf.object?.addTarget(strongSelf, action: #selector(EventTarget.run(_:)), for: event)
            }
        }
        
        self.removeListener = { [weak self]() in
            if let strongSelf = self {
                strongSelf.object?.removeTarget(strongSelf, action: #selector(EventTarget.run(_:)), for: event)
            }
        }
    }
}

internal extension EventTarget where T : UIGestureRecognizer {
    convenience init(_ object: T, runnable: @escaping (T) -> Void) {
        self.init(object, runnable: runnable)

        self.addListener = { [weak self]() in
            if let strongSelf = self {
                strongSelf.object?.addTarget(strongSelf, action: #selector(EventTarget.run(_:)))
            }
        }

        self.removeListener = { [weak self]() in
            if let strongSelf = self {
                strongSelf.object?.removeTarget(strongSelf, action: #selector(EventTarget.run(_:)))
            }
        }
    }
}

