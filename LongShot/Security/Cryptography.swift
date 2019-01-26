//
//  Cryptography.swift
//  LongShot
//
//  Created by Brandon on 2018-10-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import Security

public class Cryptography {
    
    public enum KeyType: Int {
        case rsa
        case ellipticCurve
        case ecsecPrimeRandom
    }
    
    public class func getPrivateKey(id: String) throws -> SecKey? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: id.data(using: .utf8)!,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnRef: kCFBooleanTrue as Any
        ]
        
        var result: CFTypeRef? = nil
        let error = SecItemCopyMatching(query as CFDictionary, &result)
        if error == errSecSuccess || error == errSecDuplicateItem || error == errSecInteractionNotAllowed {
            if let res = result {
                return (res as! SecKey)
            }
            return nil
        }
        
        if error == errSecItemNotFound {
            return nil
        }
        
        throw RuntimeError("OSStatus: \(error)")
    }
    
    public class func getPublicKey(id: String) throws -> SecKey? {
        if let privateKey = try getPrivateKey(id: id) {
            return SecKeyCopyPublicKey(privateKey)
        }
        return nil
    }
    
    public class func getKeyData(key: SecKey) throws -> Data? {
        var error: Unmanaged<CFError>? = nil
        if let data = SecKeyCopyExternalRepresentation(key, &error) {
            return data as Data
        }
        
        if let error = error?.takeUnretainedValue() {
            throw error
        }
        
        return nil
    }
    
    public class func setKey(id: String, key: SecKey) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: id.data(using: .utf8)!,
            kSecValueRef: key,
        ]
        
        let error = SecItemAdd(query as CFDictionary, nil)
        if error != errSecSuccess {
            throw RuntimeError("OSStatus: \(error)")
        }
    }
    
    @discardableResult
    public class func deleteKey(id: String) -> Error? {
        let error = SecItemDelete([
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: id.data(using: .utf8)!
        ] as CFDictionary)
        
        if error == errSecSuccess || error == errSecItemNotFound {
            return nil
        }
        
        return RuntimeError("OSStatus: \(error)")
    }
    
    public class func generateKey(id: String, type: KeyType, bits: UInt16, storeInKeychain: Bool = false, deleteExisting: Bool = false) throws -> SecKey? {

        if deleteExisting {
            deleteKey(id: id)
        } else {
            if let key = try getPrivateKey(id: id) {
                return key
            }
        }
        
        let keyTypes = [kSecAttrKeyTypeRSA, kSecAttrKeyTypeEC, kSecAttrKeyTypeECSECPrimeRandom]
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: keyTypes[type.rawValue],
            kSecAttrKeySizeInBits: bits,
            kSecAttrCreator: "com.longshot.security.cryptography",
            kSecPrivateKeyAttrs: [kSecAttrIsPermanent: storeInKeychain,
                                  kSecAttrApplicationTag: id.data(using: .utf8)!
            ]
        ]
        
        var error: Unmanaged<CFError>? = nil
        let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
        
        if let error = error?.takeUnretainedValue() {
            print(error as Error)
        }
        
        return key
    }
    
    private class func privateKeyExists(id: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: id.data(using: .utf8)!,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnAttributes: kCFBooleanTrue as Any
        ]
        
        var result: CFTypeRef? = nil
        let error = SecItemCopyMatching(query as CFDictionary, &result)
        if error == errSecSuccess || error == errSecDuplicateItem || error == errSecInteractionNotAllowed {
            return true
        }
        
        return false
    }
}
