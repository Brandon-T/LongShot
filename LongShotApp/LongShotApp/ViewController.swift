//
//  ViewController.swift
//  LongShotApp
//
//  Created by Brandon on 2018-01-07.
//  Copyright © 2018 XIO. All rights reserved.
//

import UIKit
import LongShot


class ContainerController : UIViewController {
    private var currentController: UIViewController?
    
    func switchToController(controller: UIViewController, duration: TimeInterval) {
        controller.view.frame = self.view.bounds
        
        if let currentController = self.currentController {
            currentController.willMove(toParentViewController: nil)
            self.addChildViewController(controller)
            
            self.transition(from: currentController, to: controller, duration: duration, options: .transitionCrossDissolve, animations: {
                
            }) { (completedTransition) in
                currentController.removeFromParentViewController()
                controller.didMove(toParentViewController: self)
                currentController.view.removeFromSuperview()
                self.currentController = controller
            }
        }
        else {
            self.addChildViewController(controller)
            self.view.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
    }
}

extension UIView {
    func pushTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionPush)
    }
}

class ViewController: UIViewController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let particle = UIView()
        particle.frame = CGRect(0, 0, 10, 10)
        particle.backgroundColor = UIColor.random()
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100).centered(in: self.view.bounds).offsetBy(dx: 0.0, dy: self.view.bounds.size.height / 2.0)
        emitterLayer.emitterPosition = emitterLayer.bounds.center()
        
        let cell = CAEmitterCell()
        cell.birthRate = 50
        cell.lifetime = 10
        cell.velocity = 200
        
        cell.emissionLongitude = CGFloat(-90.0).toRadians() //control direction of emission
        cell.emissionRange = CGFloat(-45.0).toRadians() //control angle of emission
        cell.contents = UIImage(named: "Particle")!.cgImage
        cell.scale = 0.1 //control initial size of the cell
        cell.scaleRange = 0.5 //control max size of the cell
        cell.scaleSpeed = 0.2 //control how fast the cell grows
        cell.alphaSpeed = -0.3  //-1.0 / lifetime  control the alpha of the cell
        
        emitterLayer.emitterCells = [cell]
        self.view.layer.addSublayer(emitterLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func createCustomNavigation() {
        let navigationBar = UINavigationBar()
        self.view.addSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
            ])
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.delegate = self
        
        let item = UINavigationItem(title: "Custom Navigation")
        let img = makeChevron(thickness: 3.0, size: CGSize(width: 22.0, height: 44.0), colour: nil)!
        let barButton = UIBarButtonItem(image: img, style: .done, target: nil, action: nil)
        item.leftBarButtonItems = [barButton]
        
        navigationBar.setItems([item], animated: true)
    }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func makeChevron(thickness: CGFloat, size: CGSize, colour: UIColor? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        
        let padding: CGFloat = 0.20
        let path = UIBezierPath()
        path.move(to: CGPoint(x: padding + 0.5, y: 0.773))
        path.addLine(to: CGPoint(x: padding + 0.0, y: 0.5))
        path.addLine(to: CGPoint(x: padding + 0.5, y: 0.227))
        path.apply(CGAffineTransform(scaleX: size.width, y: size.height))
        
        ctx?.setStrokeColor(colour?.cgColor ?? UIColor.white.cgColor)
        ctx?.addPath(path.cgPath)
        ctx?.setLineWidth(thickness)
        ctx?.setLineJoin(.round)
        ctx?.strokePath()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colour != nil ? img?.withRenderingMode(.alwaysOriginal) : img
    }

    func test() {
        let blocky: @convention(block) (Int, NSDictionary) -> Void = {(arg, arg2) in
            print("BLOCK \(arg) - \(arg2)")
        }
        
        let function = Function<Void>(blocky, args: 100, ["A": "B", "B": 1] as AnyObject)
        try! function.execute()
    }
}

