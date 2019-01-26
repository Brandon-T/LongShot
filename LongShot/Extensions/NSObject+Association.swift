//
//  NSObject+Association.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation


private final class GenericWrapper<T> {
    let value: T
    init(_ val: T) {
        value = val
    }
}

private final class WeakWrapper<T: AnyObject> {
    weak var value : T?
    init (_ val: T) {
        value = val
    }
}

public extension NSObject {
    private struct Association {
        static var associatedKey: Int = 0
    }
    
    func memoryAddress() -> Int {
        return Unmanaged.passUnretained(self).toOpaque().hashValue
    }
    
    func getObject<T>() -> T? {
        if let object = objc_getAssociatedObject(self, &Association.associatedKey) as? T {
            return object
        }
        else if let object = objc_getAssociatedObject(self, &Association.associatedKey) as? GenericWrapper<T> {
            return object.value
        }
        else {
            return nil
        }
    }
    
    func setObject<T>(object: T, policy: objc_AssociationPolicy) -> Void {
        objc_setAssociatedObject(self, &Association.associatedKey, object,  policy)
    }
    
    func removeObject() -> Void {
        objc_setAssociatedObject(self, &Association.associatedKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    
    
    func getObject<T>(key: String) -> T? {
        let data: [String: AnyObject]? = self.getObject()
        
        guard let object = data?[key] as? WeakWrapper<AnyObject> else {
            if let object = data?[key] as? T {
                return object
            }
            else if let object = data?[key] as? GenericWrapper<T> {
                return object.value
            }
            return nil
        }
        
        if let object = object.value as? T {
            return object
        }
        else if let object = object.value as? GenericWrapper<T> {
            return object.value
        }
        return nil
    }
    
    func setObject<T>(object: T, key: String, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> Void {
        var data: [String: AnyObject] = self.getObject() ?? [String: AnyObject]()
        data[key] = object as AnyObject
        self.setObject(object: data, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func removeObject(key: String) -> Void {
        var data: [String: AnyObject] = self.getObject() ?? [String: AnyObject]()
        data.removeValue(forKey: key)
        self.setObject(object: data, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
