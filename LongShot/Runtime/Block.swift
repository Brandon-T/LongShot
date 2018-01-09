//
//  Block.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

class Block : Invocable {
    
    private let block: AnyObject
    
    init(_ block: AnyObject) {
        self.block = block
    }
    
    init<Block>(_ block: Block) {
        self.block = block as AnyObject      //unsafeBitCast(block, to: AnyObject.self)
    }
    
//    func execute(_ args: InvocableType?...) throws -> InvocableType? {
//        var array = [InvocableType?]()
//        for type in args {
//            array.append(type)
//        }
//        return try self.execute(array)
//    }
    
    func execute(_ args: [InvocableType?]) throws -> InvocableType? {
        if (!self.isBlock()) {
            throw BlockError.notABlock
        }
        
        let signature = MethodSignature(self.blockSignature()!)
        
        if (signature.numberOfArguments() < 1) {
            throw BlockError.invalidBlockSignature //id must be first parameter..
        }
        
        if (Int(signature.numberOfArguments()) - 1) != args.count {
            throw BlockError.invalidNumberOfParameters //number of arguments do not match signature of block..
        }
        
        if let firstArgument = signature.getArgumentTypeAtIndex(0), firstArgument != "@?" { //_C_ID, isBlock
            throw BlockError.invalidBlockSignature //id, isBlock must be first parameter..
        }
        
        let invocation = MethodInvocation(signature)
        
        for i in 0..<args.count {
            invocation.setArgument(args[i], index: i + 1)
        }
        
        invocation.invokeWithTarget(self.block)
        return invocation.getReturnValue()
    }
    
    private func isBlock() -> Bool {
        var classType: AnyClass! = object_getClass(self.block)
        
        while (true) {
            let cls: AnyClass! = class_getSuperclass(classType)
            
            if cls != NSObject.self {
                classType = cls
            }
            else {
                break
            }
        }
        
        return class_getName(classType) == class_getName(NSClassFromString("NSBlock")!)
    }
    
    private func blockSignature() -> String? {
        let block = unsafeBitCast(self.block, to: UnsafePointer<BlockInfo>.self).pointee
        let descriptor = block.descriptor.pointee
        
        let signatureFlag: UInt32 = 1 << 30
        
        if (block.flags & signatureFlag != 0) {
            let signature = String(cString: descriptor.signature)
            return signature
        }
        return nil
    }
    
    
    
    private struct BlockDescriptor {
        var reserved: UInt
        var size: UInt
        
        var copy_helper: UnsafeRawPointer
        var dispose_helper: UnsafeRawPointer
        var signature: UnsafePointer<Int8>
    };
    
    private struct BlockInfo {
        var isa: UnsafeRawPointer
        var flags: UInt32
        var reserved: UInt32
        var invoke: UnsafeRawPointer
        var descriptor: UnsafePointer<BlockDescriptor>
    };
}

private enum BlockError: Error {
    case notABlock
    case invalidBlockSignature
    case invalidNumberOfParameters
    case blockReturnsNil
}
