//
//  UIView+Utilities.swift
//  LongShot
//
//  Created by Brandon on 2018-01-03.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension UIView {
    private class func getAllSubviews<T: UIView>(view: UIView) -> [T] {
        return view.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(view: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }
    
    public func getAllSubviews<T: UIView>() -> [T] {
        return UIView.getAllSubviews(view: self) as [T]
    }
}

open class LayeredView : UIView {
    private (set) var contentView = UIView()
    private var shadowColour: UIColor = .black
    private var shadowOffset: CGPoint = .zero
    private var shadowRadius: CGFloat = 0.0
    private var shadowOpacity: CGFloat = 0.0
    private var roundedCorners: UIRectCorner = .allCorners
    private var cornerRadius: CGFloat = 0.0
    private var hasShadow: Bool = false
    private var hasRoundedCorners: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        super.addSubview(self.contentView)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.bounds
        
        self.contentView.layer.mask = nil
        self.layer.sublayer(named: "com.long.shot.shadow.layer")?.removeFromSuperlayer()
        
        if self.hasShadow {
            let shadowLayer = self.layer.shadowLayer(self.shadowRadius, opacity: self.shadowOpacity, colour: self.shadowColour, offset: self.shadowOffset, cornerRadius: self.cornerRadius)
            
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            self.layer.addSublayer(shadowLayer)
        }
        
        if self.hasRoundedCorners {
            let roundedLayer = self.layer.roundLayer(self.roundedCorners, cornerRadius: self.cornerRadius)
            self.contentView.layer.mask = roundedLayer
        }
    }
    
    public func setRoundedCorners(cornerRadius: CGFloat, corners: UIRectCorner = .allCorners) {
        self.hasRoundedCorners = true
        self.roundedCorners = corners
        self.cornerRadius = cornerRadius
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    public func setShadow(shadowRadius: CGFloat, shadowOpacity: CGFloat, shadowColour: UIColor = .black, shadowOffset: CGPoint = .zero) {
        
        self.hasShadow = true
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.shadowColour = shadowColour
        self.shadowOffset = shadowOffset
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    public func removeRoundedCorners() {
        self.hasRoundedCorners = false
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    public func removeShadow() {
        self.hasShadow = false
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
