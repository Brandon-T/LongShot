//
//  Future.swift
//  LongShot
//
//  Created by Brandon on 2018-01-14.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public class Future<T> {
    private var promise: Promise<T>
    
    public init(_ promise: Promise<T>) {
        self.promise = promise
    }
    
    public func get() -> T? {
        return self.promise.getValue()
    }
}
