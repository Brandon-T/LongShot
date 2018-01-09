//
//  UIView+Animation.swift
//  LongShot
//
//  Created by Brandon on 2018-01-07.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

private struct LayerAnimation {
    let layer: CALayer
    let path: String
    let from: Any
}

extension CALayer {
    func animate() {
        self.action(forKey: <#T##String#>)
    }
}
