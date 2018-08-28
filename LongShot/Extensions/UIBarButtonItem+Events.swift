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
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(image: image, style: style, target: nil, action: nil)
        self.setEventHandler(action)
    }
    
    public convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
        self.setEventHandler(action)
    }
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.setEventHandler(action)
    }
    
    public convenience init(barButtonSystemItem systemItem: UIBarButtonSystemItem, _ action: @escaping (_ item: UIBarButtonItem) -> Void) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        self.setEventHandler(action)
    }
    
    @discardableResult
    public func setEventHandler<T>(_ runnable: @escaping (_ item: T) -> Void) -> RemovableTarget where T: UIBarButtonItem {
        return EventTarget(self) { (item) in
            runnable(item as! T)
        }
    }
}
