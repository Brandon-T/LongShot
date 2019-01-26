//
//  UIView+Animation.swift
//  LongShot
//
//  Created by Brandon on 2018-01-07.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public struct LayerAnimationOptions : OptionSet {
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let `repeat` = LayerAnimationOptions(rawValue: 1 << 0)
    public static let autoreverse = LayerAnimationOptions(rawValue: 1 << 1)
    public static let curveEaseInOut = LayerAnimationOptions(rawValue: 1 << 2)
    public static let curveEaseIn = LayerAnimationOptions(rawValue: 1 << 3)
    public static let curveEaseOut = LayerAnimationOptions(rawValue: 1 << 4)
    public static let curveLinear = LayerAnimationOptions(rawValue: 1 << 5)
    public static let systemDefault = LayerAnimationOptions(rawValue: 1 << 6)
}

public protocol LayerPathAnimation {
    init(_ layer: CALayer)
    func animate(_ path: String, duration: TimeInterval, value: Any)
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, value: Any)
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, options: LayerAnimationOptions, value: Any)
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, dampingRatio: CGFloat, initialVelocity: CGFloat, options: LayerAnimationOptions, value: Any)
}

public extension CALayer {
    
    func animate(_ animations: (_ animation: LayerPathAnimation) -> Void) {
        let animation = LayerAnimation(self)
        animations(animation)
        animation.execute()
    }
    
    func animateGroup(_ animations: (_ group: LayerPathAnimation) -> Void) {
        let group = LayerAnimationGroup(self)
        animations(group)
        group.execute()
    }
}




//Internal
private class LayerAnimator {
    class func animate(_ path: String, duration: TimeInterval, value: Any) -> CABasicAnimation {
        return self.animate(path, duration: duration, delay: 0.0, value: value)
    }
    
    class func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, value: Any) -> CABasicAnimation {
        return self.animate(path, duration: duration, delay: delay, options: [], value: value)
    }
    
    class func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, options: LayerAnimationOptions, value: Any) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: path)
        animation.toValue = value
        animation.duration = duration
        animation.beginTime = delay > 0 ? CACurrentMediaTime() + delay : 0.0;
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        self.setAnimationOptions(animation, options: options)
        return animation
    }
    
    class func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, dampingRatio: CGFloat, initialVelocity: CGFloat, options: LayerAnimationOptions, value: Any) -> CASpringAnimation {
        
        let animation = CASpringAnimation(keyPath: path)
        animation.toValue = value
        animation.duration = duration
        animation.beginTime = delay > 0 ? CACurrentMediaTime() + delay : 0.0;
        animation.damping = CGFloat(-2.0 * log(0.001) / duration)  //epsilon
        animation.mass = 1.0
        animation.stiffness = CGFloat(pow(animation.damping, 2)) / CGFloat(pow(dampingRatio * 2, 2))
        animation.initialVelocity = initialVelocity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        self.setAnimationOptions(animation, options: options)
        return animation
    }
    
    private class func setAnimationOptions(_ animation: CABasicAnimation, options: LayerAnimationOptions) {
        animation.repeatCount = options.contains(.repeat) ? .greatestFiniteMagnitude : 0
        animation.autoreverses = options.contains(.autoreverse)
        
        if (options.rawValue != 0) {
            switch options {
            case .curveEaseInOut:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                
            case .curveEaseIn:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                
            case .curveEaseOut:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                
            case .curveLinear:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                
            case .systemDefault:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                
            default:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            }
        }
    }
}

private class LayerAnimation : LayerPathAnimation {
    private let layer: CALayer
    private var animations: [CAAnimation]?
    
    required init(_ layer: CALayer) {
        self.layer = layer
        self.animations = []
    }
    
    func animate(_ path: String, duration: TimeInterval, value: Any) {
        self.animate(path, duration: duration, delay: 0.0, value: value)
    }
    
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, value: Any) {
        self.animate(path, duration: duration, delay: delay, options: [], value: value)
    }
    
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, options: LayerAnimationOptions, value: Any) {
        let animation = LayerAnimator.animate(path, duration: duration, delay: delay, options: options, value: value)
        self.animations?.append(animation)
    }
    
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, dampingRatio: CGFloat, initialVelocity: CGFloat, options: LayerAnimationOptions, value: Any) {
        let animation = LayerAnimator.animate(path, duration: duration, delay: delay, dampingRatio: dampingRatio, initialVelocity: initialVelocity, options: options, value: value)
        self.animations?.append(animation)
    }
    
    func execute() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.animations?.forEach({ [weak self](animation) in
                if let animation = animation as? CABasicAnimation {
                    self?.layer.setValue(animation.toValue, forKeyPath: animation.keyPath!)
                }
            })
            
            self.animations?.forEach({ [weak self](animation) in
                self?.layer.removeAnimation(forKey: String(describing: animation.memoryAddress()))
            })
        }
        
        if let animations = self.animations {
            for animation in animations {
                self.layer.add(animation, forKey: String(describing: animation.memoryAddress()))
            }
        }
        CATransaction.commit()
    }
}

class LayerAnimationGroup : LayerPathAnimation {
    private let layer: CALayer
    private let group: CAAnimationGroup?
    
    required init(_ layer: CALayer) {
        self.layer = layer
        self.group = CAAnimationGroup()
        self.group?.animations = []
    }
    
    func animate(_ path: String, duration: TimeInterval, value: Any) {
        self.animate(path, duration: duration, delay: 0.0, value: value)
    }
    
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, value: Any) {
        self.animate(path, duration: duration, delay: delay, options: [], value: value)
    }
    
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, options: LayerAnimationOptions, value: Any) {
        let animation = LayerAnimator.animate(path, duration: duration, delay: delay, options: options, value: value)
        self.group?.animations?.append(animation)
    }
    
    func animate(_ path: String, duration: TimeInterval, delay: TimeInterval, dampingRatio: CGFloat, initialVelocity: CGFloat, options: LayerAnimationOptions, value: Any) {
        let animation = LayerAnimator.animate(path, duration: duration, delay: delay, dampingRatio: dampingRatio, initialVelocity: initialVelocity, options: options, value: value)
        self.group?.animations?.append(animation)
    }
    
    private func finalize(_ group: CAAnimationGroup?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            group?.animations?.forEach({ [weak self](animation) in
                if let animation = animation as? CABasicAnimation {
                    self?.layer.setValue(animation.toValue, forKeyPath: animation.keyPath!)
                }
            })
            
            self.layer.removeAnimation(forKey: String(describing: group?.memoryAddress()))
        }
        self.layer.add(group!, forKey: String(describing: group?.memoryAddress()))
        CATransaction.commit()
    }
    
    private func maxDuration() -> TimeInterval {
        var maxDuration: TimeInterval = 0.0
        if let animations = self.group?.animations {
            for animation in animations {
                var endTime: TimeInterval = animation.duration
                if (animation.beginTime > 0.0) {
                    endTime += (animation.beginTime - CACurrentMediaTime())
                }
                
                maxDuration = TimeInterval.maximum(maxDuration, endTime)
            }
        }
        return maxDuration
    }
    
    func execute() {
        let duration = self.maxDuration()
        self.group?.duration = duration
        self.group?.fillMode = .both
        self.group?.isRemovedOnCompletion = false
        self.finalize(self.group)
    }
}
