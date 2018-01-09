//
//  BaseNavigationController.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

open class BaseNavigationController : UINavigationController {
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.setTheme()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setTheme()
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.setTheme()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setTheme() {
        
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let viewController = viewController as? BaseViewController {
            if viewController.prefersBackButtonText {
                viewController.navigationItem.backBarButtonItem = nil
            }
            else {
                let backButton = UIBarButtonItem(title: " ", style: .done, target: nil, action: nil)
                backButton.imageInsets = UIEdgeInsetsMake(0, 0, 10, 0);
                
                viewController.navigationItem.backBarButtonItem = backButton
            }
        }
        
        super.pushViewController(viewController, animated: animated)
        
        if let viewController = viewController as? BaseViewController {
            viewController.navigationItem.setHidesBackButton(viewController.prefersBackButtonHidden, animated: animated)
            self.setNavigationBarHidden(viewController.prefersNavigationBarHidden, animated: animated)
        }
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        let viewController = super.popViewController(animated: animated)
        
        if let viewController = visibleViewController as? BaseViewController {
            self.setNavigationBarHidden(viewController.prefersNavigationBarHidden, animated: animated)
        }
        
        return viewController
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToRootViewController(animated: animated)
        
        if let viewController = visibleViewController as? BaseViewController {
            self.setNavigationBarHidden(viewController.prefersNavigationBarHidden, animated: animated)
        }
        
        return viewControllers
    }
}
