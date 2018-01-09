//
//  RuntimeError.swift
//  LongShot
//
//  Created by Brandon on 2018-01-05.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public struct RuntimeError: Error {
    private let message: String
    
    public init(_ message: String) {
        self.message = message
    }
    
    var localizedDescription: String {
        return message
    }
}
