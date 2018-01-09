//
//  String+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation


public extension String {
    public func toDate(format: String, locale: Locale = Locale.current) -> Date? {
        let formatter = DateFormatter.defaultFormatter(locale: locale)
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    public func toNumber(locale: Locale = Locale.current) -> NSNumber? {
        return NumberFormatter.defaultFormatter(locale: locale).number(from: self)
    }
    
    public func index(_ offset: Int) -> Index {
        return self.index(self.startIndex, offsetBy: offset)
    }
    
    public func substring(from: Int) -> String {
        let startIndex = self.index(from)
        let endIndex = self.endIndex
        return String(self[startIndex..<endIndex])
    }
    
    public func substring(from: Int, to: Int) -> String {
        let startIndex = self.index(from)
        let endIndex = self.index(to)
        return String(self[startIndex..<endIndex])
    }
    
    public func substring(index: Int, count: Int) -> String {
        if index >= self.count {
            return ""
        }
        
        if index + count > self.count {
            return ""
        }
        
        return self.substring(from:index, to:index + count)
    }
    
    public subscript(range: Range<Int>) -> String {
        let start = self.index(startIndex, offsetBy: range.lowerBound)
        let end = self.index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
    
    public subscript(index: Int) -> String {
        get {
            return self.substring(index: index, count: 1)
        }
    }
}

public extension String {
    public func sizeToFit(_ font: UIFont) -> CGSize {
        let constrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let size = self.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    public func sizeThatFits(_ boundingSize: CGSize, font: UIFont) -> CGSize {
        let size = self.boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    public func asAttributedString() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: [:])
    }
    
    public func superscript(font: UIFont, baseline: Float) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.font: font, .baselineOffset: baseline])
    }
}

public extension NSAttributedString {
    public func sizeToFit() -> CGSize {
        let constrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let size = self.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    public func sizeThatFits(_ boundingSize: CGSize) -> CGSize {
        let size = self.boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
}
