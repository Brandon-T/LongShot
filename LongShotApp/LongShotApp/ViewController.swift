//
//  ViewController.swift
//  LongShotApp
//
//  Created by Brandon on 2018-01-07.
//  Copyright © 2018 XIO. All rights reserved.
//

import UIKit
import LongShot

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let promise = Promise<Int> { (resolve, reject) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                resolve(100)
            })
        }
        
        promise.then { (i) in
            print(i)
        }.then { (i) in
            print(i)
        }
        
        
        
        let navigationBar = UINavigationBar()
        self.view.addSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        let item = UINavigationItem(title: "Custom Navigation")
        let img = makeChevron(thickness: 3.0, size: CGSize(width: 22.0, height: 44.0), colour: nil)!
        let barButton = UIBarButtonItem(image: img, style: .done, target: nil, action: nil)
        item.leftBarButtonItems = [barButton]
        
        navigationBar.setItems([item], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

