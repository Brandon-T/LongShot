//
//  Preferences.swift
//  LongShot
//
//  Created by Brandon on 2018-10-10.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

/*@dynamicMemberLookup
public class Preferences {
    private let preferences = UserDefaults.standard
    
    var key: String = ""
    
    public init() {
        let ref: String = Preferences().name
    }
    
    public subscript<T>(dynamicMember member: String) -> T? {
        return UserDefaults.standard.value(forKey: member) as? T
    }
    
    public subscript<T>(dynamicMember member: KeyPath) -> T? {
        return Int("0") as! T
    }
}

extension Preferences {
    public class Option<T>: Codable where T: Codable {
        public var value: T {
            get {
                
            }
            
            set {
                
            }
        }
        
        private(set) public var key: String
        private var defaultValue: T?
        
        init(key: String, value: T, defaultValue: T? = nil) {
            self.key = key
            self.value = value
            self.defaultValue = defaultValue
        }
    }
}
*/
