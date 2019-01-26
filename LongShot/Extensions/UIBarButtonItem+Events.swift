//
//  UIBarButtonItem+Events.swift
//  LongShot
//
//  Created by Brandon on 2018-08-27.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    
    public convenience init(image: UIImage?, style: UIBarButtonItem.Style, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(image: image, style: style, target: nil, action: nil)
        self.on(action)
    }
    
    public convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItem.Style, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
        self.on(action)
    }
    
    public convenience init(title: String?, style: UIBarButtonItem.Style, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.on(action)
    }
    
    public convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        self.on(action)
    }
    
    @discardableResult
    public func on<T>(_ runnable: @escaping (_ item: T) -> Void) -> RemovableTarget where T: UIBarButtonItem {
        return EventTarget(self) { (item) in
            runnable(item as! T)
        }
    }
}
