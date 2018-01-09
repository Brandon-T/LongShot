//
//  DisplayLinkAnimator.swift
//  LongShot
//
//  Created by Brandon on 2018-01-05.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public class DisplayLinkAnimator {
    private var fromValue: Float = 0.0
    private var toValue: Float = 0.0
    private var displayLink: CADisplayLink? = nil
    private var currentTime: TimeInterval = 0.0
    private var totalTime: TimeInterval = 0.0
    private var lastUpdate: TimeInterval = 0.0
    private var frameUpdate: ((Float) -> Void)? = nil
    private var completion: (() -> Void)? = nil
    
    deinit {
        self.stopAnimating()
    }
    
    @objc
    private func onTick(displayLink: CADisplayLink) {
        let now = Date.timeIntervalSinceReferenceDate
        self.currentTime += now - self.lastUpdate
        self.lastUpdate = now
        
        if self.currentTime >= self.totalTime {
            self.displayLink?.invalidate()
            self.displayLink?.remove(from: .main, forMode: .defaultRunLoopMode)
            self.displayLink?.remove(from: .main, forMode: .UITrackingRunLoopMode)
            self.displayLink = nil
            self.currentTime = self.totalTime
        }
        
        if let onFrameUpdate = self.frameUpdate {
            let updatedValue = { () -> Float in
                if self.currentTime >= self.totalTime {
                    return self.toValue
                }
                
                let percent = Float(self.currentTime / self.totalTime)
                return self.fromValue + (percent * (self.toValue - self.fromValue))
            }
            onFrameUpdate(updatedValue())
        }
        
        if self.currentTime >= self.totalTime {
            if let completion = self.completion {
                self.frameUpdate = nil
                self.completion = nil
                completion()
            }
        }
    }
    
    public func animateWithDuration(duration: TimeInterval, from: Float, to: Float, update: @escaping (Float) -> Void, completion: (() -> Void)? = nil) {
        self.displayLink?.remove(from: .main, forMode: .defaultRunLoopMode)
        self.displayLink?.remove(from: .main, forMode: .UITrackingRunLoopMode)
        self.displayLink?.invalidate()
        self.displayLink = nil
        
        self.fromValue = from
        self.toValue = to
        self.frameUpdate = update
        self.completion = completion
        
        if duration == 0.0 {
            update(to)
            if let completion = completion {
                completion()
            }
            return
        }
        
        self.currentTime = 0.0
        self.totalTime = duration
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(onTick(displayLink:)))
        self.displayLink?.preferredFramesPerSecond = 60
        self.displayLink?.add(to: .main, forMode: .defaultRunLoopMode)
        self.displayLink?.add(to: .main, forMode: .UITrackingRunLoopMode)
    }
    
    public func stopAnimating() {
        self.displayLink?.remove(from: .main, forMode: .defaultRunLoopMode)
        self.displayLink?.remove(from: .main, forMode: .UITrackingRunLoopMode)
        self.displayLink?.invalidate()
        self.displayLink = nil
        self.frameUpdate = nil
        self.completion = nil
    }
}
