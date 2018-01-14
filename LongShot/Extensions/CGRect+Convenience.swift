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
    
    public func centered(in rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x + ((rect.width - self.width) / 2.0),
                      y: rect.origin.y + ((rect.height - self.height) / 2.0),
                      width: self.width,
                      height: self.height).integral
    }
}

public extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.origin = CGPoint(x: x, y: y)
        self.size = CGSize(width: width, height: height)
    }
    
    public var x: CGFloat {
        get { return self.origin.x }
        set { self.origin.x = newValue }
    }
    
    public var y: CGFloat {
        get { return self.origin.y }
        set { self.origin.y = newValue }
    }
    
    public var width: CGFloat {
        get { return self.size.width }
        set { self.size.width = newValue }
    }
    
    public var height: CGFloat {
        get { return self.size.height }
        set { self.size.height = newValue }
    }
    
    public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGRect {
        self = self.offsetBy(dx: dx, dy: dy)
        return self
    }
    
    public mutating func inset(dx: CGFloat, dy: CGFloat) -> CGRect {
        self = self.insetBy(dx: dx, dy: dy)
        return self
    }
    
    public mutating func inset(insets: UIEdgeInsets) -> CGRect {
        self = UIEdgeInsetsInsetRect(self, insets)
        return self
    }
    
    public mutating func scale(dx: CGFloat, dy: CGFloat) -> CGRect {
        self.size = CGSize(width: self.size.width * dx, height: self.size.height * dy)
        return self
    }
    
    public mutating func extend(dx: CGFloat, dy: CGFloat) -> CGRect {
        self.size = CGSize(width: self.size.width + dx, height: self.size.height + dy)
        return self
    }
    
    public mutating func set(x: CGFloat) -> CGRect {
        self.origin.x = x
        return self
    }
    
    public mutating func set(y: CGFloat) -> CGRect {
        self.origin.y = y
        return self
    }
    
    public mutating func set(width: CGFloat) -> CGRect {
        self.size.width = width
        return self
    }
    
    public mutating func set(height: CGFloat) -> CGRect {
        self.size.height = height
        return self
    }
    
    public mutating func set(origin: CGPoint) -> CGRect {
        self.origin = origin
        return self
    }
    
    public mutating func set(size: CGSize) -> CGRect {
        self.size = size
        return self
    }
}
