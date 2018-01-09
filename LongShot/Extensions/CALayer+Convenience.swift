//
//  CALayer+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-06.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension CALayer {
    public func sublayer(named: String) -> CALayer? {
        return self.sublayers?.first(where: { $0.name == named })
    }
    
    public func roundLayer(_ corners: UIRectCorner, cornerRadius: CGFloat) -> CALayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        layer.path = path.cgPath
        layer.frame = self.bounds
        layer.name = "com.long.shot.corner.radius.mask.layer"
        return layer
    }
    
    public func shadowLayer(_ radius: CGFloat, opacity: CGFloat, colour: UIColor = .black, offset: CGPoint = .zero, cornerRadius: CGFloat? = nil) -> CALayer {
        let layer = CAShapeLayer()
        layer.shadowRadius = radius
        layer.shadowOpacity = Float(opacity)
        layer.shadowColor = colour.cgColor
        layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        layer.frame = self.bounds
        layer.name = "com.long.shot.shadow.layer"
        
        if let cornerRadius = cornerRadius {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            layer.path = path.cgPath
        }
        return layer
    }
    
    public func addMaskLayer(_ corners: UIRectCorner, cornerRadius: CGFloat, shadowRadius: CGFloat, shadowOpacity: CGFloat, shadowColour: UIColor = .black, shadowOffset: CGPoint = .zero) {
        
        let shadowLayer = self.shadowLayer(shadowRadius, opacity: shadowOpacity, colour: shadowColour, offset: shadowOffset, cornerRadius: cornerRadius)
        
        let cornerLayer = self.roundLayer(corners, cornerRadius: cornerRadius)
        cornerLayer.masksToBounds = true
        shadowLayer.addSublayer(cornerLayer)
        self.mask = shadowLayer
    }
}
