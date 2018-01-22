//
//  Number+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension Int {
    public static func random() -> Int {
        return Int(arc4random_uniform(UInt32(Int.max)))
    }
    
    public static func random(max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    public static func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}

public extension Float {
    public func toDegrees() -> Float {
        return self * 180.0 / .pi
    }
    
    public func toRadians() -> Float {
        return self * .pi / 180.0
    }
    
    public func equals(other: Float, delta: Float = Float.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
    }
    
    public func asCurrency(locale: Locale = Locale.current) -> String? {
        return NumberFormatter.currencyFormatter(locale: locale).string(from: NSNumber(value: self))
    }
    
    public static func random() -> Float {
        return Float(arc4random()) / Float(UInt32.max)
    }
    
    public static func random(min: Float, max: Float) -> Float {
        return Float.random() * (max - min) + min
    }
    
    public func scaleToRange(fMin: Float, fMax: Float, toMin: Float, toMax: Float) -> Float {
        return (((toMax - toMax) * (self - fMin)) / (fMax - fMin)) + toMin
    }
}

public extension Double {
    public func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
    
    public func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    public func equals(other: Double, delta: Double = Double.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
    }
    
    public func asCurrency(locale: Locale = Locale.current) -> String? {
        return NumberFormatter.currencyFormatter(locale: locale).string(from: NSNumber(value: self))
    }
    
    public static func random() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
    
    public static func random(min: Double, max: Double) -> Double {
        return Double.random() * (max - min) + min
    }
    
    public func scaleToRange(fMin: Double, fMax: Double, toMin: Double, toMax: Double) -> Double {
        return (((toMax - toMax) * (self - fMin)) / (fMax - fMin)) + toMin
    }
}

public extension CGFloat {
    public func toDegrees() -> CGFloat {
        return self * 180.0 / .pi
    }
    
    public func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
    
    public func equals(other: CGFloat, delta: CGFloat = CGFloat.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
    }
    
    public static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
    
    public func scaleToRange(fMin: CGFloat, fMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
        return (((toMax - toMax) * (self - fMin)) / (fMax - fMin)) + toMin
    }
}

public extension NumberFormatter {
    public class func defaultFormatter(locale: Locale = Locale.current) -> NumberFormatter {
        struct Formatter {
            static let formatter: NumberFormatter = {
                let result = NumberFormatter()
                result.numberStyle = .decimal
                return result
            }()
        }
        
        Formatter.formatter.locale = locale
        Formatter.formatter.numberStyle = .decimal
        return Formatter.formatter
    }
    
    public class func currencyFormatter(locale: Locale = Locale.current) -> NumberFormatter {
        struct Formatter {
            static let formatter: NumberFormatter = {
                let result = NumberFormatter()
                result.numberStyle = .currency
                return result
            }()
        }
        
        Formatter.formatter.locale = locale
        Formatter.formatter.numberStyle = .currency
        return Formatter.formatter
    }
}
