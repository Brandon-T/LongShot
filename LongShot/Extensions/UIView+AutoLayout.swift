//
//  UIView+AutoLayout.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    public func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}

public protocol Constrainable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: Constrainable {}
extension UILayoutGuide: Constrainable {}

public extension UIView {
    @discardableResult
    public func pin(_ constraints: [NSLayoutConstraint]) -> Self {
        NSLayoutConstraint.activate(constraints)
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult
    public func pin(to constrainable: Constrainable, insets: UIEdgeInsets = .zero) -> Self {
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: constrainable.leftAnchor, constant: insets.left),
            topAnchor.constraint(equalTo: constrainable.topAnchor, constant: insets.top),
            rightAnchor.constraint(equalTo: constrainable.rightAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: -insets.bottom)
        ])
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    // MARK: -
    
    @discardableResult
    public func pin(_ anchors: [ConstraintAnchor] = [.pinned(.zero)]) -> Self {
        if let superview = self.superview {
            return self.pin(to: superview, anchors)
        }
        
        fatalError("\(self) is not part of the view hierarchy")
    }
    
    @discardableResult
    public func pin(to constrainable: Constrainable, _ anchors: [ConstraintAnchor]) -> Self {
        anchors.compactMap({
            resolve($0, constrainable)
        }).forEach({
            $0.isActive = true
        })
        
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}


public struct ConstraintAnchor {
    internal let anchor: ConstraintAnchorType
    
    /// Pins left to left
    public static let left = ConstraintAnchor(anchor: .left(0.0, .required))
    
    /// Pins right to left
    public static let leftRight = ConstraintAnchor(anchor: .leftRight(0.0, .required))
    
    /// Pins right to right
    public static let right = ConstraintAnchor(anchor: .right(0.0, .required))
    
    /// Pins right to Left
    public static let rightLeft = ConstraintAnchor(anchor: .rightLeft(0.0, .required))
    
    /// Pins top to top
    public static let top = ConstraintAnchor(anchor: .top(0.0, .required))
    
    /// Pins top to bottom
    public static let topBottom = ConstraintAnchor(anchor: .topBottom(0.0, .required))
    
    /// Pins bottom to bottom
    public static let bottom = ConstraintAnchor(anchor: .bottom(0.0, .required))
    
    /// Pins bottom to top
    public static let bottomTop = ConstraintAnchor(anchor: .bottomTop(0.0, .required))
    
    /// Pins width to width
    public static let width = ConstraintAnchor(anchor: .width(-1.0, .required))
    
    /// Pins width to height
    public static let widthHeight = ConstraintAnchor(anchor: .widthHeight(.required))
    
    /// Pins height to height
    public static let height = ConstraintAnchor(anchor: .height(-1.0, .required))
    
    /// Pins height to width
    public static let heightWidth = ConstraintAnchor(anchor: .heightWidth(.required))
    
    /// Pins centerX to centerX
    public static let centerX = ConstraintAnchor(anchor: .centerX(0.0, .required))
    
    /// Pins centerY to centerY
    public static let centerY = ConstraintAnchor(anchor: .centerY(0.0, .required))
    
    /// Pins all around
    public static let pinned = ConstraintAnchor(anchor: .pinned(.zero))
}

extension ConstraintAnchor {
    /// Pins left to left
    public static func left(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .left(offset, priority))
    }
    
    /// Pins left to left
    public static func left(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .leftOf(constrainable, offset, priority))
    }
    
    /// Pins left to right
    public static func leftRight(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .leftRight(offset, priority))
    }
    
    /// Pins left to right
    public static func leftRight(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .leftRightOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins right to right
    public static func right(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .right(offset, priority))
    }
    
    /// Pins right to right
    public static func right(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .rightOf(constrainable, offset, priority))
    }
    
    /// Pins right to left
    public static func rightLeft(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .rightLeft(offset, priority))
    }
    
    /// Pins right to left
    public static func rightLeft(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .rightLeftOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins top to top
    public static func top(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .top(offset, priority))
    }
    
    /// Pins top to top
    public static func top(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .topOf(constrainable, offset, priority))
    }
    
    /// Pins top to bottom
    public static func topBottom(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .topBottom(offset, priority))
    }
    
    /// Pins top to bottom
    public static func topBottom(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .topBottomOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins bottom to bottom
    public static func bottom(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .bottom(offset, priority))
    }
    
    /// Pins bottom to bottom
    public static func bottom(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .bottomOf(constrainable, offset, priority))
    }
    
    /// Pins bottom to top
    public static func bottomTop(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .bottomTop(offset, priority))
    }
    
    /// Pins bottom to top
    public static func bottomTop(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .bottomTopOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins width to width
    public static func width(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .width(offset, priority))
    }
    
    /// Pins width to width
    public static func widthOf(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .widthOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins height to height
    public static func height(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .height(offset, priority))
    }
    
    /// Pins height to height
    public static func heightOf(_ constrainable: Constrainable, _ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .heightOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins centerX to centerX
    public static func centerX(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .centerX(offset, priority))
    }
    
    /// Pins centerX to centerX
    public static func centerX(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .centerXOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins centerY to centerY
    public static func centerY(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .centerY(offset, priority))
    }
    
    /// Pins centerY to centerY
    public static func centerYOf(_ constrainable: Constrainable, _ offset: CGFloat = 0.0, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .centerYOf(constrainable, offset, priority))
    }
}

extension ConstraintAnchor {
    /// Pins all around
    public static func pinned(_ insets: UIEdgeInsets) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .pinned(insets))
    }
    
    /// Pins greater than some other constraint
    public static func greaterThan(_ anchor: ConstraintAnchor) -> ConstraintAnchor {
        if case .greaterThan = anchor.anchor {
            fatalError("Invalid Constraint")
        }
        
        if case .lessThan = anchor.anchor {
            fatalError("Invalid Constraint")
        }
        
        if case .pinned = anchor.anchor {
            fatalError("Invalid Constraint")
        }
        
        return ConstraintAnchor(anchor: .greaterThan(anchor.anchor))
    }
    
    /// Pins less than some other constraint
    public static func lessThan(_ anchor: ConstraintAnchor) -> ConstraintAnchor {
        if case .greaterThan = anchor.anchor {
            fatalError("Invalid Constraint")
        }
        
        if case .lessThan = anchor.anchor {
            fatalError("Invalid Constraint")
        }
        
        if case .pinned = anchor.anchor {
            fatalError("Invalid Constraint")
        }
        
        return ConstraintAnchor(anchor: .lessThan(anchor.anchor))
    }
}



// MARK: - Internal
private extension UIView {
    private func resolve(_ anchor: ConstraintAnchor, _ constrainable: Constrainable) -> NSLayoutConstraint? {
        switch anchor.anchor {
        // MARK: -
        case .left(let offset, let priority):
            return self.leftAnchor.constraint(equalTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftRight(let offset, let priority):
            return self.rightAnchor.constraint(equalTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftOf(let constrainable, let offset, let priority):
            return self.leftAnchor.constraint(equalTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftRightOf(let constrainable, let offset, let priority):
            return self.rightAnchor.constraint(equalTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .right(let offset, let priority):
            return self.rightAnchor.constraint(equalTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightLeft(let offset, let priority):
            return self.leftAnchor.constraint(equalTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightOf(let constrainable, let offset, let priority):
            return self.rightAnchor.constraint(equalTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightLeftOf(let constrainable, let offset, let priority):
            return self.leftAnchor.constraint(equalTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .top(let offset, let priority):
            return self.topAnchor.constraint(equalTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topBottom(let offset, let priority):
            return self.bottomAnchor.constraint(equalTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topOf(let constrainable, let offset, let priority):
            return self.topAnchor.constraint(equalTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topBottomOf(let constrainable, let offset, let priority):
            return self.bottomAnchor.constraint(equalTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .bottom(let offset, let priority):
            return self.bottomAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomTop(let offset, let priority):
            return self.topAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomOf(let constrainable, let offset, let priority):
            return self.bottomAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomTopOf(let constrainable, let offset, let priority):
            return self.topAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .width(let width, let priority):
            return width < 0.0 ? self.widthAnchor.constraint(equalTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(equalToConstant: width).priority(priority)
            
        case .widthHeight(let priority):
            return self.widthAnchor.constraint(equalTo: constrainable.heightAnchor).priority(priority)
            
        case .widthOf(let constrainable, let width, let priority):
            return width < 0.0 ? self.widthAnchor.constraint(equalTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(equalToConstant: width).priority(priority)
            
        // MARK: -
        case .height(let height, let priority):
            return height < 0.0 ? self.heightAnchor.constraint(equalTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(equalToConstant: height).priority(priority)
            
        case .heightWidth(let priority):
            return self.heightAnchor.constraint(equalTo: constrainable.widthAnchor).priority(priority)
            
        case .heightOf(let constrainable, let height, let priority):
            return height < 0.0 ? self.heightAnchor.constraint(equalTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(equalToConstant: height).priority(priority)
            
        // MARK: -
        case .centerX(let offset, let priority):
            return self.centerXAnchor.constraint(equalTo: constrainable.centerXAnchor, constant: offset).priority(priority)
            
        case .centerXOf(let constrainable, let offset, let priority):
            return self.centerXAnchor.constraint(equalTo: constrainable.centerXAnchor, constant: offset).priority(priority)
            
        case .centerY(let offset, let priority):
            return self.centerYAnchor.constraint(equalTo: constrainable.centerYAnchor, constant: offset).priority(priority)
            
        case .centerYOf(let constrainable, let offset, let priority):
            return self.centerYAnchor.constraint(equalTo: constrainable.centerYAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .pinned(let insets):
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: constrainable.leftAnchor, constant: insets.left),
                self.rightAnchor.constraint(equalTo: constrainable.rightAnchor, constant: -insets.right),
                self.topAnchor.constraint(equalTo: constrainable.topAnchor, constant: insets.top),
                self.bottomAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: -insets.bottom)
            ])
            return nil
            
        case .greaterThan(let type):
            return resolveGreater(type, constrainable)
            
        case .lessThan(let type):
            return resolveLess(type, constrainable)
        }
    }
    
    private func resolveGreater(_ anchor: ConstraintAnchorType, _ constrainable: Constrainable) -> NSLayoutConstraint? {
        switch anchor {
        // MARK: -
        case .left(let offset, let priority):
            return self.leftAnchor.constraint(greaterThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftRight(let offset, let priority):
            return self.rightAnchor.constraint(greaterThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftOf(let constrainable, let offset, let priority):
            return self.leftAnchor.constraint(greaterThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftRightOf(let constrainable, let offset, let priority):
            return self.rightAnchor.constraint(greaterThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .right(let offset, let priority):
            return self.rightAnchor.constraint(greaterThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightLeft(let offset, let priority):
            return self.leftAnchor.constraint(greaterThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightOf(let constrainable, let offset, let priority):
            return self.rightAnchor.constraint(greaterThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightLeftOf(let constrainable, let offset, let priority):
            return self.leftAnchor.constraint(greaterThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .top(let offset, let priority):
            return self.topAnchor.constraint(greaterThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topBottom(let offset, let priority):
            return self.bottomAnchor.constraint(greaterThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topOf(let constrainable, let offset, let priority):
            return self.topAnchor.constraint(greaterThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topBottomOf(let constrainable, let offset, let priority):
            return self.bottomAnchor.constraint(greaterThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .bottom(let offset, let priority):
            return self.bottomAnchor.constraint(greaterThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomTop(let offset, let priority):
            return self.topAnchor.constraint(greaterThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomOf(let constrainable, let offset, let priority):
            return self.bottomAnchor.constraint(greaterThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomTopOf(let constrainable, let offset, let priority):
            return self.topAnchor.constraint(greaterThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .width(let width, let priority):
            return width < 0.0 ? self.widthAnchor.constraint(greaterThanOrEqualTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(greaterThanOrEqualToConstant: width).priority(priority)
            
        case .widthHeight(let priority):
            return self.widthAnchor.constraint(greaterThanOrEqualTo: constrainable.heightAnchor).priority(priority)
            
        case .widthOf(let constrainable, let width, let priority):
            return width < 0.0 ? self.widthAnchor.constraint(greaterThanOrEqualTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(greaterThanOrEqualToConstant: width).priority(priority)
            
        // MARK: -
        case .height(let height, let priority):
            return height < 0.0 ? self.heightAnchor.constraint(greaterThanOrEqualTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(greaterThanOrEqualToConstant: height).priority(priority)
            
        case .heightWidth(let priority):
            return self.heightAnchor.constraint(greaterThanOrEqualTo: constrainable.widthAnchor).priority(priority)
            
        case .heightOf(let constrainable, let height, let priority):
            return height < 0.0 ? self.heightAnchor.constraint(greaterThanOrEqualTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(greaterThanOrEqualToConstant: height).priority(priority)
            
        // MARK: -
        case .centerX(let offset, let priority):
            return self.centerXAnchor.constraint(greaterThanOrEqualTo: constrainable.centerXAnchor, constant: offset).priority(priority)
            
        case .centerXOf(let constrainable, let offset, let priority):
            return self.centerXAnchor.constraint(greaterThanOrEqualTo: constrainable.centerXAnchor, constant: offset).priority(priority)
            
        case .centerY(let offset, let priority):
            return self.centerYAnchor.constraint(greaterThanOrEqualTo: constrainable.centerYAnchor, constant: offset).priority(priority)
            
        case .centerYOf(let constrainable, let offset, let priority):
            return self.centerYAnchor.constraint(greaterThanOrEqualTo: constrainable.centerYAnchor, constant: offset).priority(priority)
            
        // MARK: -
        default:
            fatalError("Invalid Greater Than Constraint")
        }
    }
    
    private func resolveLess(_ anchor: ConstraintAnchorType, _ constrainable: Constrainable) -> NSLayoutConstraint? {
        switch anchor {
        // MARK: -
        case .left(let offset, let priority):
            return self.leftAnchor.constraint(lessThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftRight(let offset, let priority):
            return self.rightAnchor.constraint(lessThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftOf(let constrainable, let offset, let priority):
            return self.leftAnchor.constraint(lessThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        case .leftRightOf(let constrainable, let offset, let priority):
            return self.rightAnchor.constraint(lessThanOrEqualTo: constrainable.leftAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .right(let offset, let priority):
            return self.rightAnchor.constraint(lessThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightLeft(let offset, let priority):
            return self.leftAnchor.constraint(lessThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightOf(let constrainable, let offset, let priority):
            return self.rightAnchor.constraint(lessThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        case .rightLeftOf(let constrainable, let offset, let priority):
            return self.leftAnchor.constraint(lessThanOrEqualTo: constrainable.rightAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .top(let offset, let priority):
            return self.topAnchor.constraint(lessThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topBottom(let offset, let priority):
            return self.bottomAnchor.constraint(lessThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topOf(let constrainable, let offset, let priority):
            return self.topAnchor.constraint(lessThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        case .topBottomOf(let constrainable, let offset, let priority):
            return self.bottomAnchor.constraint(lessThanOrEqualTo: constrainable.topAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .bottom(let offset, let priority):
            return self.bottomAnchor.constraint(lessThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomTop(let offset, let priority):
            return self.topAnchor.constraint(lessThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomOf(let constrainable, let offset, let priority):
            return self.bottomAnchor.constraint(lessThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        case .bottomTopOf(let constrainable, let offset, let priority):
            return self.topAnchor.constraint(lessThanOrEqualTo: constrainable.bottomAnchor, constant: offset).priority(priority)
            
        // MARK: -
        case .width(let width, let priority):
            return width < 0.0 ? self.widthAnchor.constraint(lessThanOrEqualTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(lessThanOrEqualToConstant: width).priority(priority)
            
        case .widthHeight(let priority):
            return self.widthAnchor.constraint(lessThanOrEqualTo: constrainable.heightAnchor).priority(priority)
            
        case .widthOf(let constrainable, let width, let priority):
            return width < 0.0 ? self.widthAnchor.constraint(lessThanOrEqualTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(lessThanOrEqualToConstant: width).priority(priority)
            
        // MARK: -
        case .height(let height, let priority):
            return height < 0.0 ? self.heightAnchor.constraint(lessThanOrEqualTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(lessThanOrEqualToConstant: height).priority(priority)
            
        case .heightWidth(let priority):
            return self.heightAnchor.constraint(lessThanOrEqualTo: constrainable.widthAnchor).priority(priority)
            
        case .heightOf(let constrainable, let height, let priority):
            return height < 0.0 ? self.heightAnchor.constraint(lessThanOrEqualTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(lessThanOrEqualToConstant: height).priority(priority)
            
        // MARK: -
        case .centerX(let offset, let priority):
            return self.centerXAnchor.constraint(lessThanOrEqualTo: constrainable.centerXAnchor, constant: offset).priority(priority)
            
        case .centerXOf(let constrainable, let offset, let priority):
            return self.centerXAnchor.constraint(lessThanOrEqualTo: constrainable.centerXAnchor, constant: offset).priority(priority)
            
        case .centerY(let offset, let priority):
            return self.centerYAnchor.constraint(lessThanOrEqualTo: constrainable.centerYAnchor, constant: offset).priority(priority)
            
        case .centerYOf(let constrainable, let offset, let priority):
            return self.centerYAnchor.constraint(lessThanOrEqualTo: constrainable.centerYAnchor, constant: offset).priority(priority)
            
        // MARK: -
        default:
            fatalError("Invalid Less Than Constraint")
        }
    }
}

// MARK: - Internal
internal indirect enum ConstraintAnchorType {
    case left(CGFloat, UILayoutPriority)
    case leftRight(CGFloat, UILayoutPriority)
    case leftOf(Constrainable, CGFloat, UILayoutPriority)
    case leftRightOf(Constrainable, CGFloat, UILayoutPriority)
    
    case right(CGFloat, UILayoutPriority)
    case rightLeft(CGFloat, UILayoutPriority)
    case rightOf(Constrainable, CGFloat, UILayoutPriority)
    case rightLeftOf(Constrainable, CGFloat, UILayoutPriority)
    
    case top(CGFloat, UILayoutPriority)
    case topBottom(CGFloat, UILayoutPriority)
    case topOf(Constrainable, CGFloat, UILayoutPriority)
    case topBottomOf(Constrainable, CGFloat, UILayoutPriority)
    
    case bottom(CGFloat, UILayoutPriority)
    case bottomTop(CGFloat, UILayoutPriority)
    case bottomOf(Constrainable, CGFloat, UILayoutPriority)
    case bottomTopOf(Constrainable, CGFloat, UILayoutPriority)
    
    case width(CGFloat, UILayoutPriority)
    case widthHeight(UILayoutPriority)
    case widthOf(Constrainable, CGFloat, UILayoutPriority)
    
    case height(CGFloat, UILayoutPriority)
    case heightWidth(UILayoutPriority)
    case heightOf(Constrainable, CGFloat, UILayoutPriority)
    
    case centerX(CGFloat, UILayoutPriority)
    case centerXOf(Constrainable, CGFloat, UILayoutPriority)
    
    case centerY(CGFloat, UILayoutPriority)
    case centerYOf(Constrainable, CGFloat, UILayoutPriority)
    
    case pinned(UIEdgeInsets)
    case greaterThan(ConstraintAnchorType)
    case lessThan(ConstraintAnchorType)
}
