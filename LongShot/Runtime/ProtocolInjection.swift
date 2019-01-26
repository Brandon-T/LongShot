//
//  ProtocolInjection.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension NSObject {
    class func classFromString(_ cls: String, interface: Protocol?) -> NSObject.Type? {
        guard let interface = interface else {
            return NSClassFromString(cls) as? NSObject.Type
        }
        
        if let cls = NSClassFromString(cls) {
            if class_conformsToProtocol(cls, interface) {
                return cls as? NSObject.Type
            }
            
            if class_addProtocol(cls, interface) {
                return cls as? NSObject.Type
            }
        }
        return nil
    }

    class func classFromString<T>(_ cls: String, interface: Protocol?) -> T? {
        return classFromString(cls, interface: interface) as? T
    }

    class func instanceFromString<T>(_ cls: String, interface: Protocol?) -> T? {
        return classFromString(cls, interface: interface)?.init() as? T
    }
}
