//
//  CGPoint+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-06.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension CGPoint {
    public func distance(to: CGPoint) -> CGFloat {
        let x = to.x - self.x
        let y = to.y - self.y
        return ((x * x) + (y * y)) //sqrt(pow(to.x - self.x, 2) + pow(to.y - self.y, 2))
    }
}
