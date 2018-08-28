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
        return sqrt((x * x) + (y * y)) //sqrt(pow(to.x - self.x, 2) + pow(to.y - self.y, 2))
    }
    
    public func distanceSq(to: CGPoint) -> CGFloat {
        let x = to.x - self.x
        let y = to.y - self.y
        return ((x * x) + (y * y))
    }
    
    public func magnitude() -> CGFloat {
        return sqrt((self.x * self.x) + (self.y * self.y))
    }
    
    public func magnitudeSq() -> CGFloat {
        return ((self.x * self.x) + (self.y * self.y))
    }
    
    public func normalized() -> CGPoint {
        let magnitude = self.magnitude()
        if (magnitude > 0) {
            var point = self
            point.x /= magnitude
            point.y /= magnitude
            return point
        }
        return .zero
    }
    
    public mutating func normalize() -> CGPoint {
        let magnitude = self.magnitude()
        self.x /= magnitude
        self.y /= magnitude
        return self
    }
    
    public func angleXY() -> CGFloat {
        return atan2(self.y, self.x)
    }
    
    public func rotated(around point: CGPoint, byAngle radians: CGFloat) -> CGPoint {
        let transform = CGAffineTransform(translationX: -point.x, y: -point.y).rotated(by: radians).translatedBy(x: point.x, y: point.y)
        return self.applying(transform)
    }
    
    public func rotated(around point: CGPoint, byDegrees degrees: CGFloat) -> CGPoint {
        let rotationSin = sin(degrees.toRadians())
        let rotationCos = cos(degrees.toRadians())
        let x = (self.x * rotationCos - self.y * rotationSin) + point.x
        let y = (self.x * rotationSin + self.y * rotationCos) + point.y
        return CGPoint(x: x, y: y)
    }
    
    public func pointAtAngle(origin: CGPoint, distance: CGFloat, radians: CGFloat) -> CGPoint {
        return CGPoint(x: origin.x + distance * cos(radians), y: origin.y + distance * sin(radians))
    }
    
    func isInCircle(center: CGPoint, radius: CGFloat) -> Bool {
        return self.distance(to: center) < radius
    }
    
    func isInRect(_ rect: CGRect) -> Bool {
        return rect.contains(self)
    }
}

public extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init()
        self.x = x
        self.y = y
    }
    
    public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        self.x += dx
        self.y += dy
        return self
    }
}
