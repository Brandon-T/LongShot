//
//  PresentationFrameAnimator.swift
//  LongShot
//
//  Created by Brandon on 2018-09-30.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

class PresentationFrameAnimator : NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    private var isPresenting: Bool = false
    private var startFrame: CGRect = .zero
    private var endFrame: CGRect = UIScreen.main.bounds
    private var minAlpha: CGFloat = 0.0
    
    init(startFrame: CGRect?, endFrame: CGRect?) {
        super.init()
        
        if startFrame != nil {
            self.startFrame = startFrame!
        }
        
        if endFrame != nil {
            self.endFrame = endFrame!
        }
        
        if self.startFrame.isEmpty {
            self.startFrame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }
        
        if self.endFrame.isEmpty {
            self.endFrame = UIScreen.main.bounds
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            let toViewController = transitionContext.viewController(forKey: .to)!
            
            transitionContext.containerView.addSubview(toViewController.view)
            toViewController.view.frame = self.endFrame
            toViewController.view.setNeedsLayout()
            toViewController.view.layoutIfNeeded()
            
            let transform = CGAffineTransform.transform(from: self.endFrame, toRect: self.startFrame)
            toViewController.view.transform = transform
            toViewController.view.alpha = toViewController.modalTransitionStyle == .crossDissolve ? self.minAlpha : 1.0
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
                
                toViewController.view.transform = .identity
                toViewController.view.alpha = 1.0
                toViewController.view.layoutIfNeeded()
                
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
        else {
            let fromController = transitionContext.viewController(forKey: .from)!
            fromController.view.setNeedsLayout()
            fromController.view.layoutIfNeeded()
            
            let transform = CGAffineTransform.transform(from: self.endFrame, toRect: self.startFrame)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                
                fromController.view.transform = transform
                fromController.view.alpha = fromController.modalTransitionStyle == .crossDissolve ? self.minAlpha : 1.0
                fromController.view.layoutIfNeeded()
                
            }, completion: { (finished) in
                fromController.view.removeFromSuperview()
                fromController.view.transform = .identity
                fromController.view.alpha = 1.0
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
}
