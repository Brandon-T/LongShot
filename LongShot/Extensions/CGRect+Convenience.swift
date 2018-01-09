//
//  CGRect+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension CGRect {
    public func center() -> CGPoint {
        return CGPoint(x: self.origin.x + (self.width / 2.0), y: self.origin.y + (self.height / 2.0))
    }
    
    public func centeredInRect(rect: CGRect) -> CGRect {
        return CGRect.centeredRectInRect(parent: rect, child: self)
    }
    
    public static func centeredRectInRect(parent: CGRect, child: CGRect) -> CGRect {
        return CGRect(x: parent.origin.x + ((parent.width - child.width) / 2.0),
                      y: parent.origin.y + ((parent.height - child.height) / 2.0),
                      width: child.width,
                      height: child.height).integral
    }
}
