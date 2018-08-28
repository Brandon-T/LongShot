//
//  UIStackView+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-08-27.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension UIStackView {
    @discardableResult
    func addArrangedSubviews(_ views: [UIView]) -> Self {
        views.forEach({ addArrangedSubview($0) })
        return self
    }
}
