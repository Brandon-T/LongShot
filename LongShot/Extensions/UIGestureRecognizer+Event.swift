//
//  UIGestureRecognizer+Event.swift
//  LongShot
//
//  Created by Brandon on 2018-01-05.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public extension UIGestureRecognizer {
    
    @discardableResult
    public func addEventHandler<T>(_ runnable: @escaping (_ recognizer: T) -> Void) -> RemovableTarget where T: UIGestureRecognizer {
        return EventTarget(self) { (recognizer) in
            runnable(recognizer as! T)
        }
    }
}
