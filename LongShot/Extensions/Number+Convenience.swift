//
//  Number+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension Float {
    public func toDegrees() -> Float {
        return self * .pi / 180.0
    }
    
    public func toRadians() -> Float {
        return self * 180.0 / .pi
    }
    
    public func equals(other: Float, delta: Float = Float.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
    }
    
    public func asCurrency(locale: Locale = Locale.current) -> String? {
        return NumberFormatter.currencyFormatter(locale: locale).string(from: NSNumber(value: self))
    }
}

public extension Double {
    public func toDegrees() -> Double {
        return self * .pi / 180.0
    }
    
    public func toRadians() -> Double {
        return self * 180.0 / .pi
    }
    
    public func equals(other: Double, delta: Double = Double.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
    }
    
    public func asCurrency(locale: Locale = Locale.current) -> String? {
        return NumberFormatter.currencyFormatter(locale: locale).string(from: NSNumber(value: self))
    }
}

public extension CGFloat {
    public func toDegrees() -> CGFloat {
        return self * .pi / 180.0
    }
    
    public func toRadians() -> CGFloat {
        return self * 180.0 / .pi
    }
    
    public func equals(other: CGFloat, delta: CGFloat = CGFloat.ulpOfOne) -> Bool {
        return fabs(self - other) < delta
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
