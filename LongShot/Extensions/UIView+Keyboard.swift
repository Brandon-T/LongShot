//
//  UIView+Keyboard.swift
//  LongShot
//
//  Created by Brandon on 2018-09-30.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

extension UIView {
    private enum KeyboardAdjuster: String {
        case TapGestureRecognizerKey
        case DidAdjustFrameKey
        case OriginalAdjusterFrameKey
    }
    
    func startKeyboardListener() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func stopKeyboardListener() -> Void {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setTapOutside(enabled: Bool) -> Void {
        let tapGestureRecognizer: UITapGestureRecognizer? = self.getObject(key: KeyboardAdjuster.TapGestureRecognizerKey.rawValue)
        
        if enabled {
            if tapGestureRecognizer == nil {
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOutside))
                gestureRecognizer.numberOfTapsRequired = 1
                gestureRecognizer.name = KeyboardAdjuster.TapGestureRecognizerKey.rawValue
                
                self.addGestureRecognizer(gestureRecognizer)
                self.setObject(object: gestureRecognizer, key: KeyboardAdjuster.TapGestureRecognizerKey.rawValue)
            }
        }
        else {
            if tapGestureRecognizer != nil {
                self.removeGestureRecognizer(tapGestureRecognizer!)
                self.removeObject(key: KeyboardAdjuster.TapGestureRecognizerKey.rawValue)
            }
        }
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) -> Void {
        let didAdjustFrame: Bool = self.getObject(key: KeyboardAdjuster.DidAdjustFrameKey.rawValue) ?? false
        
        if !didAdjustFrame {
            self.setObject(object: self.frame, key: KeyboardAdjuster.OriginalAdjusterFrameKey.rawValue)
        }
        
        self.setObject(object: true, key: KeyboardAdjuster.DidAdjustFrameKey.rawValue)
        
        
        let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        
        let curveInfo = UIView.AnimationCurve(rawValue: (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0) ?? .linear
        
        let duration = TimeInterval((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(curveInfo)
        UIView.setAnimationDuration(duration)
        
        self.frame = self.getObject(key: KeyboardAdjuster.OriginalAdjusterFrameKey.rawValue)!
        self.frame.origin.y -= endFrame.size.height
        UIView.commitAnimations()
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) -> Void {
        let didAdjustFrame: Bool = self.getObject(key: KeyboardAdjuster.DidAdjustFrameKey.rawValue) ?? false
        
        if didAdjustFrame {
            self.setObject(object: false, key: KeyboardAdjuster.DidAdjustFrameKey.rawValue)
            
            let curveInfo = UIView.AnimationCurve(rawValue: (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0) ?? .linear
            
            let duration = TimeInterval((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationCurve(curveInfo)
            UIView.setAnimationDuration(duration)
            
            self.frame = self.getObject(key: KeyboardAdjuster.OriginalAdjusterFrameKey.rawValue)!
            UIView.commitAnimations()
        }
    }
    
    @objc
    func onTapOutside(gestureRecognizer: UITapGestureRecognizer) {
        self.resignFirstResponder()
        self.endEditing(true)
    }
}
