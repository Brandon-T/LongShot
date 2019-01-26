//
//  UITableView+Reusability.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public protocol ReusableTableViewCell {
    func prepareForReuse()
}

public extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        if let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T {
            return cell
        }
        fatalError("Cannot Dequeue Cell With Identifier \(identifier)")
    }
    
    func dequeueReusableView<T: UITableViewHeaderFooterView>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        if let view = self.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T {
            return view
        }
        fatalError("Cannot Dequeue View With Identifier \(identifier)")
    }
    
    func register<T: UITableViewCell>(cell _: T.Type) {
        let identifier = String(describing: T.self)
        self.register(T.self, forCellReuseIdentifier: identifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(view _: T.Type) {
        let identifier = String(describing: T.self)
        self.register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

public extension UITableViewCell {
    func removeSeparatorInsets() {
        self.separatorInset = .zero
    }
    
    func removeSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: UIScreen.main.bounds.width * 2.0)
    }
}

public final class GenericTableSupplementaryView<ContentView> : UITableViewHeaderFooterView where ContentView : UIView {
    public let view = ContentView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.doLayout()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        if let view = self.view as? ReusableTableViewCell {
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
    
    override public var layoutMargins: UIEdgeInsets {
        get {
            return .zero
        }
        
        set (newValue) {
            super.layoutMargins = .zero
        }
    }
}

public final class GenericTableCell<ContentView> : UITableViewCell where ContentView : UIView {
    public let view = ContentView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.doLayout()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        if let view = self.view as? ReusableTableViewCell {
            view.prepareForReuse()
        }
    }
    
    private func doLayout() {
        self.contentView.addSubview(self.view)
        self.selectionStyle = .none
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
    
    public override var layoutMargins: UIEdgeInsets {
        get {
            return .zero
        }
        
        set (newValue) {
            super.layoutMargins = .zero
        }
    }
}
