//
//  TickingLabel.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public final class TickingLabel : UILabel {
    private var animator: DisplayLinkAnimator?
    private var formatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }()
    
    public func animateWithDuration(duration: TimeInterval, from: Float, to: Float, frameUpdate: ((TickingLabel, String) -> Void)? = nil, completion: (() -> Void)? = nil) {

        self.animator = DisplayLinkAnimator()
        self.animator?.animateWithDuration(duration: duration, from: from, to: to, update: { [weak self](value) in
            
            if let strongSelf = self {
                if let onFrameUpdate = frameUpdate {
                    onFrameUpdate(strongSelf, strongSelf.formatter.string(for: NSNumber(value: value)) ?? "")
                }
                else {
                    strongSelf.text = strongSelf.formatter.string(for: NSNumber(value: value))
                }
            }
            
            }, completion: { [weak self]() in
                
                self?.animator?.stopAnimating()
                
                if let completion = completion {
                    completion()
                }
            })
    }
    
    deinit {
        self.animator?.stopAnimating();
        self.animator = nil
    }
}
