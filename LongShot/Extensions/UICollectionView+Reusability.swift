//
//  UICollectionView+Reusability.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public protocol ReusableCollectionViewCell {
    func prepareForReuse()
}

public enum UICollectionElementKind {
    case header
    case footer
}

public extension UICollectionView {
    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        if let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        }
        fatalError("Cannot Dequeue Cell With Identifier \(identifier)")
    }
    
    public func dequeueReusableView<T: UIView>(for indexPath: IndexPath, kind: UICollectionElementKind) -> T {
        let identifier = String(describing: T.self)
        if let view = self.dequeueReusableSupplementaryView(ofKind: kind == .header ? UICollectionElementKindSectionHeader : UICollectionElementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as? T {
            return view
        }
        fatalError("Cannot Dequeue View With Identifier \(identifier)")
    }
    
    public func register<T: UICollectionViewCell>(cell _: T.Type) {
        let identifier = String(describing: T.self)
        self.register(T.self, forCellWithReuseIdentifier: identifier)
    }
    
    public func register<T: UIView>(view _: T.Type, kind: UICollectionElementKind) {
        let identifier = String(describing: T.self)
        self.register(T.self, forSupplementaryViewOfKind: kind == .header ? UICollectionElementKindSectionHeader : UICollectionElementKindSectionFooter, withReuseIdentifier: identifier)
    }
}

public final class GenericCollectionSupplementaryView<ContentView> : UICollectionReusableView where ContentView : UIView {
    public let view = ContentView()
    
    init() {
        super.init(frame: .zero)
        self.doLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.doLayout()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        if let view = self.view as? ReusableCollectionViewCell {
            view.prepareForReuse()
        }
    }
    
    private func doLayout() {
        self.addSubview(self.view)
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        self.view.pin(to: self.layoutMarginsGuide)
    }
    
    public var viewMargins: UIEdgeInsets {
        get {
            return self.layoutMargins
        }
        
        set (newValue) {
            self.layoutMargins = newValue
        }
    }
}

public final class GenericCollectionViewCell<ContentView> : UICollectionViewCell where ContentView : UIView {
    public let view = ContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.doLayout()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        if let view = self.view as? ReusableCollectionViewCell {
            view.prepareForReuse()
        }
    }
    
    private func doLayout() {
        self.contentView.addSubview(self.view)
        self.contentView.preservesSuperviewLayoutMargins = false
        self.contentView.layoutMargins = .zero
        self.view.pin(to: self.contentView.layoutMarginsGuide)
    }
    
    public var viewMargins: UIEdgeInsets {
        get {
            return self.contentView.layoutMargins
        }
        
        set (newValue) {
            self.contentView.layoutMargins = newValue
        }
    }
}
