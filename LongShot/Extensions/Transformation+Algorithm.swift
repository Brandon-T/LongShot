//
//  Transformation+Algorithm.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension CGAffineTransform {
    static func transform(from: CGRect, toRect to: CGRect) -> CGAffineTransform {
        let transform = CGAffineTransform(translationX: to.midX - from.midX, y: to.midY - from.midY)
        return transform.scaledBy(x: to.width / from.width, y: to.height / from.height)
    }
    
    func toTransform3D() -> CATransform3D {
        return CATransform3DMakeAffineTransform(self)
    }
}

public extension CATransform3D {
    static func rotate(x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, x.toRadians(), 1.0, 0.0, 0.0)
        transform = CATransform3DRotate(transform, y.toRadians(), 0.0, 1.0, 0.0)
        transform = CATransform3DRotate(transform, z.toRadians(), 0.0, 0.0, 1.0)
        return transform
    }
    
    static func scale(x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, x, y, z)
        return transform
    }
    
    static func translate(x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, x, y, z)
        return transform
    }
    
    mutating func rotate(x: CGFloat, y: CGFloat, z: CGFloat) {
        self = CATransform3DConcat(self, CATransform3D.rotate(x: x, y: y, z: z))
    }
    
    mutating func scale(x: CGFloat, y: CGFloat, z: CGFloat) {
        self = CATransform3DConcat(self, CATransform3D.scale(x: x, y: y, z: z))
    }
    
    mutating func translate(x: CGFloat, y: CGFloat, z: CGFloat) {
        self = CATransform3DConcat(self, CATransform3D.translate(x: x, y: y, z: z))
    }
    
    mutating func apply(transform: CATransform3D) {
        self = CATransform3DConcat(self, transform)
    }
    
    func toAffineTransformation() -> CGAffineTransform {
        return CGAffineTransform(a: self.m11, b: self.m12, c: self.m21, d: self.m22, tx: self.m41, ty: self.m42)
    }
}

public extension UIView {
    func rotate(x: CGFloat, y: CGFloat, z: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DRotate(transform, x.toRadians(), 1.0, 0.0, 0.0)
        transform = CATransform3DRotate(transform, y.toRadians(), 0.0, 1.0, 0.0)
        transform = CATransform3DRotate(transform, z.toRadians(), 0.0, 0.0, 1.0)
        self.layer.transform.apply(transform: transform)
    }
    
    func scale(x: CGFloat, y: CGFloat, z: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DScale(transform, x, y, z)
        self.layer.transform.apply(transform: transform)
    }
    
    func translate(x: CGFloat, y: CGFloat, z: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DTranslate(transform, x, y, z)
        self.layer.transform.apply(transform: transform)
    }
}
