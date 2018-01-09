//
//  NSDate+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension DateFormatter {
    public class func defaultFormatter(locale: Locale = Locale.current) -> DateFormatter {
        struct Formatter {
            static let formatter: DateFormatter = {
                let result = DateFormatter()
                result.dateStyle = .short
                return result
            }()
        }
        
        Formatter.formatter.locale = locale
        Formatter.formatter.dateFormat = "MM/dd/yyyy"
        Formatter.formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
        Formatter.formatter.dateStyle = .short
        return Formatter.formatter
    }
}

public extension Date {
    public func toString(format: String, locale: Locale = Locale.current) -> String {
        let formatter = DateFormatter.defaultFormatter(locale: locale)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    public func stripTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
    
    public func equalsIgnoringTime(_ other: Date) -> Bool {
        let calendar = Calendar.current
        let first = calendar.dateComponents([.year, .month, .day], from: self)
        let second = calendar.dateComponents([.year, .month, .day], from: self)
        return first.year == second.year && first.month == second.month && first.day == second.day
    }
    
    public func equals(_ other: Date) -> Bool {
        return self.compare(other) == .orderedSame
    }
    
    public func isEarlierThan(_ other: Date) -> Bool {
        return self.compare(other) == .orderedAscending
    }
    
    public func isLaterThan(_ other: Date) -> Bool {
        return self.compare(other) == .orderedDescending
    }
    
    public func isBetween(_ first: Date, _ second: Date) -> Bool {
        return self.isEarlierThan(second) && self.isLaterThan(first)
    }
    
    public func isSameDay(_ other: Date) -> Bool {
        let calendar = Calendar.current
        let first = calendar.dateComponents([.year, .month, .day], from: self)
        let second = calendar.dateComponents([.year, .month, .day], from: self)
        return first.year == second.year && first.month == second.month && first.day == second.day
    }
    
    public func isSameMonth(_ other: Date) -> Bool {
        let calendar = Calendar.current
        let first = calendar.dateComponents([.year, .month], from: self)
        let second = calendar.dateComponents([.year, .month], from: self)
        return first.year == second.year && first.month == second.month
    }
    
    public func isSameYear(_ other: Date) -> Bool {
        let calendar = Calendar.current
        let first = calendar.dateComponents([.year], from: self)
        let second = calendar.dateComponents([.year], from: self)
        return first.year == second.year
    }
}
