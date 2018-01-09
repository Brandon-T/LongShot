//
//  Func.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

class Func : Invocable {
    private let this: AnyObject!
    private let selector: Selector!
    
    init(_ this: AnyObject, selector: Selector) {
        self.this = this;
        self.selector = selector;
    }
    
    func execute(_ args: InvocableType?...) throws -> InvocableType? {
        return try self.execute(args)
    }
    
    func execute(_ args: [InvocableType?]) throws -> InvocableType? {
        let signature = MethodSignature(this, selector: selector);
        let invocation = MethodInvocation(signature)
        
        for i in 0..<args.count {
            invocation.setArgument(args[i], index: i + 2)
        }
        
        invocation.setSelector(selector: selector)
        invocation.setTarget(target: this)
        invocation.invoke()
        return invocation.getReturnValue()
    }
}
