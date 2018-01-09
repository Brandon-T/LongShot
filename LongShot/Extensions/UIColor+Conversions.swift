//
//  UIColor+Conversions.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        self.init(hex: UInt32(hex, radix: 16) ?? 0x000000, alpha: alpha)
    }
    
    public convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = UInt8((hex & 0xFF0000) >> 16)
        let g = UInt8((hex & 0xFF00) >> 8)
        let b = UInt8(hex & 0xFF)
        self.init(red8: r, green8: g, blue8: b, alpha: alpha)
    }
    
    public convenience init(red8: UInt8, green8: UInt8, blue8: UInt8, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red8) / 255.0, green: CGFloat(green8) / 255.0, blue: CGFloat(blue8) / 255.0, alpha: alpha)
    }
    
    public func componentsF() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var (r, g, b, a) = (CGFloat(0.0),
                            CGFloat(0.0),
                            CGFloat(0.0),
                            CGFloat(0.0))
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        }
        return (0.0, 0.0, 0.0, 0.0)
    }
    
    public func componentsB() -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        var (r, g, b, a) = (CGFloat(0.0),
                            CGFloat(0.0),
                            CGFloat(0.0),
                            CGFloat(0.0))
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (UInt8(r * 255.0), UInt8(g * 255.0), UInt8(b * 255.0), UInt8(a * 255.0))
        }
        return (0, 0, 0, 0)
    }
    
    public func toHex() -> UInt32 {
        let (r, g, b, a) = self.componentsB()
        if a > 0 {
            if a < 1 {
                //32-bit
                var result = (UInt32(a) << 24)
                result |= (UInt32(r) << 16)
                result |= (UInt32(g) << 8)
                result |= UInt32(b)
                return result
            }
            
            //24-bit
            return ((UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b))
        }
        return 0
    }
    
    public func toString() -> String {
        return "#\(String(self.toHex(), radix: 16, uppercase: true))"
    }
}
