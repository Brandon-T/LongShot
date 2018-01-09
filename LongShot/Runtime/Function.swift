//
//  Function.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public class BlockFunction<T> {
    private let ptr: Invocable!
    
    public init<Func>(_ block: Func) {
        self.ptr = Block(block)
    }
    
    public init(_ instanceObject: AnyObject, function: Selector) {
        self.ptr = Func(instanceObject, selector: function)
    }
    
    public func execute(args: [Invocable.InvocableType]) throws -> T {
        let result = try BlockFunction.cast(from: self.ptr.execute(args)) as T;
        
        if T.self == Void.self {
            return Void() as! T
        }
        
        return result
    }
    
    public func execute(args: Invocable.InvocableType...) throws -> T {
        let result = try BlockFunction.cast(from: self.ptr.execute(args)) as T;
        
        if T.self == Void.self {
            return Void() as! T
        }
        
        return result
    }
    
    
    
    private class func cast<T>(from v: Any?)-> T {
        if T.self == Void.self {
            return Void() as! T
        }
        return v as! T
    }
    
    private class func cast<T>(from v: Any?) -> T where T: ExpressibleByNilLiteral {
        guard let v = v else { return nil }
        return v as! T
    }
}

public class Function<T> {
    private let ptr: () throws -> T
    
    public init<Func>(_ block: Func, args: [Invocable.InvocableType]) {
        self.ptr = {() throws -> T in
            let result = try Function.cast(from: Block(block).execute(args)) as T;
            
            if T.self == Void.self {
                return Void() as! T
            }
            
            return result
        }
    }
    
    public convenience init<Func>(_ block: Func, args: Invocable.InvocableType...) {
        self.init(block, args: args)
    }
    
    public func execute() throws -> T {
        return try self.ptr()
    }
    
    
    
    private class func cast<T>(from v: Any?)-> T {
        if T.self == Void.self {
            return Void() as! T
        }
        return v as! T
    }
    
    private class func cast<T>(from v: Any?) -> T where T: ExpressibleByNilLiteral {
        guard let v = v else { return nil }
        return v as! T
    }
}


postfix operator ^
public postfix func ^ <T>(function: Function<T>) throws -> T {
    return try function.execute()
}
