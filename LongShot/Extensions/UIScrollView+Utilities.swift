//
//  UIScrollView+Utilities.swift
//  LongShot
//
//  Created by Brandon on 2018-01-07.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension UIScrollView {
    func calculateContentSize() -> CGSize {
        return self.subviews.reduce(CGRect(), { $0.union($1.frame) }).size
    }
}
