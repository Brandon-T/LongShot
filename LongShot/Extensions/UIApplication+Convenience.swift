//
//  UIApplication+Convenience.swift
//  LongShot
//
//  Created by Brandon on 2018-01-05.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension UIApplication {
    func bundleId() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    class func version() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    class func build() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = UIApplication.version() as String
        let build = UIApplication.build() as String
        return version == build ? "v\(version)" : "v\(version) build: \(build)"
    }
}
