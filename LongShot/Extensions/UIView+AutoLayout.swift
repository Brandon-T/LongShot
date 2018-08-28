//
//  UIView+AutoLayout.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public enum ConstraintAnchorType {
    case left(CGFloat, UILayoutPriority)
    case right(CGFloat, UILayoutPriority)
    case top(CGFloat, UILayoutPriority)
    case bottom(CGFloat, UILayoutPriority)
    case width(CGFloat, UILayoutPriority)
    case height(CGFloat, UILayoutPriority)
    case centerX(CGFloat, UILayoutPriority)
    case centerY(CGFloat, UILayoutPriority)
    case pinned(UIEdgeInsets)
}

public struct ConstraintAnchor {
    public let anchor: ConstraintAnchorType
    
    public static let left = ConstraintAnchor(anchor: .left(0.0, .required))
    public static let right = ConstraintAnchor(anchor: .right(0.0, .required))
    public static let top = ConstraintAnchor(anchor: .top(0.0, .required))
    public static let bottom = ConstraintAnchor(anchor: .bottom(0.0, .required))
    public static let width = ConstraintAnchor(anchor: .width(-1.0, .required))
    public static let height = ConstraintAnchor(anchor: .height(-1.0, .required))
    public static let centerX = ConstraintAnchor(anchor: .centerX(0.0, .required))
    public static let centerY = ConstraintAnchor(anchor: .centerY(0.0, .required))
    public static let pinned = ConstraintAnchor(anchor: .pinned(.zero))
    
    public static func left(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .left(offset, priority))
    }
    
    public static func right(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .right(offset, priority))
    }
    
    public static func top(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .top(offset, priority))
    }
    
    public static func bottom(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .bottom(offset, priority))
    }
    
    public static func width(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .width(offset, priority))
    }
    
    public static func height(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .height(offset, priority))
    }
    
    public static func centerX(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .centerX(offset, priority))
    }
    
    public static func centerY(_ offset: CGFloat, _ priority: UILayoutPriority = .required) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .centerY(offset, priority))
    }
    
    public static func pinned(_ insets: UIEdgeInsets) -> ConstraintAnchor {
        return ConstraintAnchor(anchor: .pinned(insets))
    }
}

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
        anchors.compactMap({ anchor -> NSLayoutConstraint? in
            switch anchor.anchor {
            case .left(let offset, let priority):
                return self.leftAnchor.constraint(equalTo: constrainable.leftAnchor, constant: offset).priority(priority)
                
            case .right(let offset, let priority):
                return self.rightAnchor.constraint(equalTo: constrainable.rightAnchor, constant: offset).priority(priority)
                
            case .top(let offset, let priority):
                return self.topAnchor.constraint(equalTo: constrainable.topAnchor, constant: offset).priority(priority)
                
            case .bottom(let offset, let priority):
                return self.bottomAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: offset).priority(priority)

            case .width(let width, let priority):
                return width < 0.0 ? self.widthAnchor.constraint(equalTo: constrainable.widthAnchor).priority(priority) : self.widthAnchor.constraint(equalToConstant: width).priority(priority)

            case .height(let height, let priority):
                return height < 0.0 ? self.heightAnchor.constraint(equalTo: constrainable.heightAnchor).priority(priority) : self.heightAnchor.constraint(equalToConstant: height).priority(priority)
                
            case .centerX(let offset, let priority):
                return self.centerXAnchor.constraint(equalTo: constrainable.centerXAnchor, constant: offset).priority(priority)
                
            case .centerY(let offset, let priority):
                return self.centerYAnchor.constraint(equalTo: constrainable.centerYAnchor, constant: offset).priority(priority)
                
            case .pinned(let insets):
                NSLayoutConstraint.activate([
                    self.leftAnchor.constraint(equalTo: constrainable.leftAnchor, constant: insets.left),
                    self.rightAnchor.constraint(equalTo: constrainable.rightAnchor, constant: -insets.right),
                    self.topAnchor.constraint(equalTo: constrainable.topAnchor, constant: insets.top),
                    self.bottomAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: -insets.bottom)
                ])
                return nil
            }
        }).forEach({
            $0.isActive = true
        })
        
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
