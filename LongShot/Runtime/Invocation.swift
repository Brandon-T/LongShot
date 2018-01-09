//
//  Invocation.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

@objc
protocol Allocatable {
    static func alloc() -> NSObject
}

@objc
protocol Invocation {
    static func invocationWithMethodSignature(_ signature: AnyObject) -> Invocation
    func methodSignatureForSelector(_ selector: Selector) -> AnyObject?
    func setTarget(_ target: NSObject)
    func setSelector(_ selector: Selector)
    func setArgument(_ buffer: UnsafeRawPointer, atIndex: NSInteger)
    func getReturnValue(_ buffer: UnsafeRawPointer)
    func methodReturnLength() -> UInt
    func invoke()
}

public extension NSObject {
    public class func instantiate(_ cls: NSObject.Type, selector: Selector, args: AnyObject...) -> NSObject! {
        if !class_conformsToProtocol(NSObject.self, Allocatable.self) {
            class_addProtocol(NSObject.self, Allocatable.self)
        }
        
        let memory: NSObject = (cls as! Allocatable.Type).alloc()
        return memory.performSelector(selector, withArgs: args).takeUnretainedValue() as! NSObject
    }
    
    public func performSelector(_ selector: Selector, withArgs args: [AnyObject]) -> Unmanaged<AnyObject>! {
        if !class_conformsToProtocol(NSObject.self, Invocation.self) {
            class_addProtocol(NSObject.self, Invocation.self)
        }
        
        let signature = (self as! Invocation).methodSignatureForSelector(selector)
        
        let invocationClass: Invocation.Type = NSObject.classFromString("NSInvocation", interface: Invocation.self)!
        let invocation = invocationClass.invocationWithMethodSignature(signature!)
        
        invocation.setTarget(self)
        invocation.setSelector(selector)
        
        for i in 0..<args.count {
            var arg = args[i]
            invocation.setArgument(&arg, atIndex: i + 2)
        }
        
        invocation.invoke()
        
        if signature!.methodReturnLength() > 0 {
            var result: UnsafeRawPointer? = nil
            invocation.getReturnValue(&result)
            return result != nil ? Unmanaged<AnyObject>.fromOpaque(result!) : nil
        }
        
        return nil
    }
    
    public func performSelector(selector: Selector, withArgs args: AnyObject...) -> Unmanaged<AnyObject>! {
        return self.performSelector(selector, withArgs: args)
    }
}
