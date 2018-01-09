//
//  UIView+AutoLayout.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    @discardableResult
    public func constrain(_ constraints: [NSLayoutConstraint]) -> Self {
        NSLayoutConstraint.activate(constraints)
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult
    public func pinTo(insets: UIEdgeInsets = .zero, safeArea: Bool = false) -> Self {
        if let superview = self.superview {
            return self.pinTo(superview, insets: insets, safeArea: safeArea)
        }
        
        fatalError("View: \(self) is not part of the View Hierarchy!")
    }
    
    @discardableResult
    public func pinTo(_ view: UIView, insets: UIEdgeInsets = .zero, safeArea: Bool = false) -> Self {
        if safeArea {
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: insets.left),
                self.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: insets.right),
                self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: insets.top),
                self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: insets.bottom)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left),
                self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
            ])
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult
    public func pinTo(_ margins: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: insets.right),
            self.topAnchor.constraint(equalTo: margins.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: insets.bottom)
        ])
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
