//
//  Invocable.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public protocol Invocable {
    typealias InvocableType = Any
//    func execute(_ args: InvocableType?...) throws -> InvocableType?
    func execute(_ args: [InvocableType?]) throws -> InvocableType?
}
