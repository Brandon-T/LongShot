//
//  Runtime.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import ObjectiveC

private func bridge<T: AnyObject>(_ object: T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(object).toOpaque())
}

private func bridge<T: AnyObject>(_ ptr: UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

private func bridge(_ object: AnyObject) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(object).toOpaque())
}

private func bridge(_ ptr: UnsafeRawPointer) -> AnyObject {
    return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue()
}

class MethodSignature {
    private var signature: NSObject?
    
    init(_ signature: NSObject?) {
        self.signature = signature
    }
    
    init(_ signature: String) {
        let methodSignature = { (signature: NSString) -> NSObject? in
            if let imp = Runtime.classIMP("signatureWithObjCTypes:") {
                typealias funcPtr = @convention(c) (AnyObject?, Selector?, UnsafePointer<Int8>) -> NSObject?
                let signatureWithObjCTypes = unsafeBitCast(imp, to: funcPtr.self)
                
                if let signature = signatureWithObjCTypes(Runtime.methodSignatureClass(), nil, signature.utf8String!) {
                    return signature
                }
            }
            return nil
        }
        
        if let methodSignature = methodSignature(signature as NSString) {
            self.signature = methodSignature
        }
    }
    
    convenience init(_ instance: AnyObject, selector: Selector) {
        let methodSignature = { () -> NSObject? in
            if let imp = Runtime.instanceIMP(instance, selector: "methodSignatureForSelector:") {
                typealias funcPtr = @convention(c) (AnyObject?, Selector?, Selector?) -> NSObject
                
                let methodSignatureForSelector = unsafeBitCast(imp, to: funcPtr.self)
                return methodSignatureForSelector(instance, nil, selector)
            }
            return nil
        }
        
        self.init(methodSignature()!)
    }
    
    func numberOfArguments() -> UInt {
        if let _ = self.signature, let imp = Runtime.instanceIMP("numberOfArguments") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> UInt
            let numberOfArguments = unsafeBitCast(imp, to: funcPtr.self)
            
            return numberOfArguments(self.signature!, nil)
        }
        return 0
    }
    
    func getArgumentTypeAtIndex(_ idx: UInt) -> String? {
        if let _ = self.signature, let imp = Runtime.instanceIMP("getArgumentTypeAtIndex:") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?, UInt) -> UnsafePointer<Int8>
            let getArgumentTypeAtIndex = unsafeBitCast(imp, to: funcPtr.self)
            let cString = getArgumentTypeAtIndex(self.signature!, nil, idx)
            
            return String(cString: cString)
        }
        return nil
    }
    
    func methodReturnLength() -> UInt {
        if let _ = self.signature, let imp = Runtime.instanceIMP("methodReturnLength") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> UInt
            let methodReturnLength = unsafeBitCast(imp, to: funcPtr.self)
            return methodReturnLength(self.signature!, nil)
        }
        return 0
    }
    
    func getSignature() -> NSObject? {
        return signature;
    }
    
    
    private class Runtime {
        public class func methodSignatureClass() -> NSObject.Type? {
            return NSClassFromString("NSMethodSignature") as? NSObject.Type
        }
        
        public class func classSelector(_ selector: String) -> Selector? {
            if let cls = methodSignatureClass() {
                return method_getName(class_getClassMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func instanceSelector(_ selector: String) -> Selector? {
            if let cls = methodSignatureClass() {
                return method_getName(class_getInstanceMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func classIMP(_ selector: String) -> IMP? {
            if let cls = methodSignatureClass() {
                return method_getImplementation(class_getClassMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func instanceIMP(_ selector: String) -> IMP? {
            if let cls = methodSignatureClass() {
                return method_getImplementation(class_getInstanceMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func instanceIMP(_ instance: AnyObject, selector: String) -> IMP? {
            if let cls = object_getClass(instance) {
                return method_getImplementation(class_getInstanceMethod(cls, Selector(selector))!)
            }
            return nil
        }
    }
}

class MethodInvocation {
    private var invocation: NSObject?
    
    private init(_ signature: NSObject) {
        let invocationWithMethodSignature = {(methodSignature: NSObject) -> NSObject? in
            if let imp = Runtime.classIMP("invocationWithMethodSignature:") {
                typealias funcPtr = @convention(c) (AnyObject?, Selector?, NSObject) -> NSObject?
                let invocationWithMethodSignature = unsafeBitCast(imp, to: funcPtr.self)
                
                if let invocation = invocationWithMethodSignature(Runtime.invocationSignatureClass(), nil, methodSignature) {
                    return invocation
                }
            }
            return nil
        }
        
        self.invocation = invocationWithMethodSignature(signature)
    }
    
    convenience init(_ signature: MethodSignature) {
        self.init(signature.getSignature()!)
    }
    
    func methodSignature() -> MethodSignature? {
        if let imp = Runtime.instanceIMP("methodSignature") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> NSObject?
            let methodSignature = unsafeBitCast(imp, to: funcPtr.self)
            
            if let signature = methodSignature(self.invocation, nil) {
                return MethodSignature(signature)
            }
        }
        return nil
    }
    
    func retainArguments() {
        if let imp = Runtime.instanceIMP("retainArguments") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> Void
            let retainArguments = unsafeBitCast(imp, to: funcPtr.self)
            
            retainArguments(self.invocation, nil)
        }
    }
    
    func argumentsRetained() -> Bool? {
        if let imp = Runtime.instanceIMP("argumentsRetained") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> Bool
            let argumentsRetained = unsafeBitCast(imp, to: funcPtr.self)
            
            return argumentsRetained(self.invocation, nil)
        }
        return nil
    }
    
    func target() -> NSObject? {
        if let imp = Runtime.instanceIMP("target") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> NSObject?
            let target = unsafeBitCast(imp, to: funcPtr.self)
            
            return target(self.invocation, nil)
        }
        return nil
    }
    
    func selector() -> Selector? {
        if let imp = Runtime.instanceIMP("selector") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> Selector
            let selector = unsafeBitCast(imp, to: funcPtr.self)
            
            return selector(self.invocation, nil)
        }
        return nil
    }
    
    func getArgument(_ index: Int) -> AnyObject? {
        if let imp = Runtime.instanceIMP("getArgument:atIndex:") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?, UnsafeRawPointer, Int) -> Void
            let getArgument = unsafeBitCast(imp, to: funcPtr.self)
            
            var argument: UnsafeRawPointer?
            getArgument(self.invocation, nil, &argument, index)
            
            if argument != nil {
                return bridge(argument!)
            }
            return nil
        }
        return nil
    }
    
    func getReturnValue() -> AnyObject? {
        if let signature = self.methodSignature(), signature.methodReturnLength() > 0 {
            
            if let imp = Runtime.instanceIMP("getReturnValue:") {
                typealias funcPtr = @convention(c) (AnyObject?, Selector?, UnsafeRawPointer) -> Void
                let getReturnValue = unsafeBitCast(imp, to: funcPtr.self)
                
                var result: UnsafeRawPointer?
                getReturnValue(self.invocation, nil, &result)
                
                if result != nil {
                    return bridge(result!
                    )
                }
                return nil
            }
        }
        return nil
    }
    
    func setTarget(target: AnyObject?) {
        if let imp = Runtime.instanceIMP("setTarget:") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?, AnyObject?) -> Void
            let setTarget = unsafeBitCast(imp, to: funcPtr.self)
            
            setTarget(self.invocation, nil, target)
        }
    }
    
    func setSelector(selector: Selector?) {
        if let imp = Runtime.instanceIMP("setSelector:") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?, Selector?) -> Void
            let setSelector = unsafeBitCast(imp, to: funcPtr.self)
            
            setSelector(self.invocation, nil, selector)
        }
    }
    
    func setArgument(_ argument: Any?, index: Int) {
        if let imp = Runtime.instanceIMP("setArgument:atIndex:") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?, UnsafeRawPointer, Int) -> Void
            let setArgument = unsafeBitCast(imp, to: funcPtr.self)
            
            var arg = argument
            setArgument(self.invocation, nil, &arg, index)
        }
    }
    
    func invoke() {
        if let imp = Runtime.instanceIMP("invoke") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?) -> Void
            let invoke = unsafeBitCast(imp, to: funcPtr.self)
            
            invoke(self.invocation, nil)
        }
    }
    
    func invokeWithTarget(_ target: AnyObject) {
        if let imp = Runtime.instanceIMP("invokeWithTarget:") {
            typealias funcPtr = @convention(c) (AnyObject?, Selector?, AnyObject) -> Void
            let invokeWithTarget = unsafeBitCast(imp, to: funcPtr.self)
            
            invokeWithTarget(self.invocation, nil, target)
        }
    }
    
    private class Runtime {
        public class func invocationSignatureClass() -> NSObject.Type? {
            return NSClassFromString("NSInvocation") as? NSObject.Type
        }
        
        public class func classSelector(_ selector: String) -> Selector? {
            if let cls = invocationSignatureClass() {
                return method_getName(class_getClassMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func instanceSelector(_ selector: String) -> Selector? {
            if let cls = invocationSignatureClass() {
                return method_getName(class_getInstanceMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func classIMP(_ selector: String) -> IMP? {
            if let cls = invocationSignatureClass() {
                return method_getImplementation(class_getClassMethod(cls, Selector(selector))!)
            }
            return nil
        }
        
        public class func instanceIMP(_ selector: String) -> IMP? {
            if let cls = invocationSignatureClass() {
                return method_getImplementation(class_getInstanceMethod(cls, Selector(selector))!)
            }
            return nil
        }
    }
}
