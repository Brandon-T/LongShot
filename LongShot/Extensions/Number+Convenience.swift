//
//  Number+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension Int {
    static func random() -> Int {
        return Int(arc4random_uniform(UInt32(Int.max)))
    }
    
    static func random(max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    static func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}

public extension Float {
    func toDegrees() -> Float {
        return self * 180.0 / .pi
    }
    
    func toRadians() -> Float {
        return self * .pi / 180.0
    }
    
    func equals(other: Float, delta: Float = Float.ulpOfOne) -> Bool {
        return abs(self - other) < delta
    }
    
    func asCurrency(locale: Locale = Locale.current) -> String? {
        return NumberFormatter.currencyFormatter(locale: locale).string(from: NSNumber(value: self))
    }
    
    static func random() -> Float {
        return Float(arc4random()) / Float(UInt32.max)
    }
    
    static func random(min: Float, max: Float) -> Float {
        return Float.random() * (max - min) + min
    }
    
    func scaleToRange(fMin: Float, fMax: Float, toMin: Float, toMax: Float) -> Float {
        return (((toMax - toMax) * (self - fMin)) / (fMax - fMin)) + toMin
    }
}

public extension Double {
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
    
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func equals(other: Double, delta: Double = Double.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
    }
    
    func asCurrency(locale: Locale = Locale.current) -> String? {
        return NumberFormatter.currencyFormatter(locale: locale).string(from: NSNumber(value: self))
    }
    
    static func random() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
    
    static func random(min: Double, max: Double) -> Double {
        return Double.random() * (max - min) + min
    }
    
    func scaleToRange(fMin: Double, fMax: Double, toMin: Double, toMax: Double) -> Double {
        return (((toMax - toMax) * (self - fMin)) / (fMax - fMin)) + toMin
    }
}

public extension CGFloat {
    func toDegrees() -> CGFloat {
        return self * 180.0 / .pi
    }
    
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
    
    func equals(other: CGFloat, delta: CGFloat = CGFloat.ulpOfOne) -> Bool {
        return abs(self - other) < delta
    }
    
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
    
    func scaleToRange(fMin: CGFloat, fMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
        return (((toMax - toMax) * (self - fMin)) / (fMax - fMin)) + toMin
    }
}

public extension NumberFormatter {
    class func defaultFormatter(locale: Locale = Locale.current) -> NumberFormatter {
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
    
    class func currencyFormatter(locale: Locale = Locale.current) -> NumberFormatter {
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
