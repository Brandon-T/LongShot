//
//  UIFont+Utilities.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension UIFont {
    public class func printFamilyNames() {
        for name in familyNames {
            print(fontNames(forFamilyName: name))
        }
    }
}
