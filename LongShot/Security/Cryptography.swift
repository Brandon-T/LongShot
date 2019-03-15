//
//  Cryptography.swift
//  LongShot
//
//  Created by Brandon on 2018-10-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import Security

/// An error class representing an error that has occurred when handling encryption
public struct CryptographyError: Error {
    //The error domain
    public let domain: String
    
    //The error code
    public let code: Int32
    
    //A description of the error
    public let description: String?
    
    init(code: Int32, description: String? = nil) {
        self.domain = "com.longshot.security.cryptography"
        self.code = code
        self.description = description
    }
}

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
        
        throw CryptographyError(code: error)
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
            throw CryptographyError(code: error)
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
        
        return CryptographyError(code: error)
    }
    
    public class func generateKey(id: String, type: KeyType, bits: UInt16, storeInKeychain: Bool = false, deleteExisting: Bool = false) throws -> SecKey? {
        return try generateKey(id: id, type: type, bits: bits, storeInKeychain: storeInKeychain, deleteExisting: deleteExisting, secureEnclave: false, controlFlags: nil)
    }
    
    public class func generateKey(id: String, type: KeyType, bits: UInt16, storeInKeychain: Bool = false, deleteExisting: Bool = false, secureEnclave: Bool, controlFlags: SecAccessControl?) throws -> SecKey? {
        
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
            kSecAttrTokenID: (secureEnclave ? kSecAttrTokenIDSecureEnclave : nil) as Any,
            kSecPrivateKeyAttrs: [kSecAttrIsPermanent: storeInKeychain,
                                  kSecAttrApplicationTag: id.data(using: .utf8)!,
                                  kSecAttrAccessControl : (controlFlags ?? nil) as Any
            ]
        ]
        
        var error: Unmanaged<CFError>? = nil
        let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
        
        if let error = error?.takeUnretainedValue() {
            throw error as Error
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

class KeychainCryptography {
    private let tag = "com.longshot.security.cryptography.private.key"
    
    public static let shared = KeychainCryptography()
    
    private init() {
        
    }
    
    /// Encrypts data using ECSECPrimeRandom-256-bit SHA512-AES-GCM algorithm and returns the result.
    /// If SHA512-AES-GCM is not supported, falls back to SHA256-AES-GCM.
    public func encrypt(_ data: Data) throws -> Data {
        var existingKey = try getKey()
        if existingKey == nil {
            existingKey = try generateKey()
        }
        
        guard let pKey = existingKey else {
            throw CryptographyError(code: -1, description: "Unable to get secure enclave keys")
        }
        
        guard let publicKey = SecKeyCopyPublicKey(pKey) else {
            throw CryptographyError(code: -1, description: "Unable to get secure enclave keys")
        }
        
        var algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA512AESGCM
        if #available(iOS 11.0, *) {
            algorithm = .eciesEncryptionCofactorVariableIVX963SHA512AESGCM
        }
        
        if !SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) {
            if #available(iOS 11.0, *) {
                algorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            } else {
                algorithm = .eciesEncryptionCofactorX963SHA256AESGCM
            }
            
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                throw CryptographyError(code: -1, description: "Encryption Algorithm not supported")
            }
        }
        
        //let blockSize = SecKeyGetBlockSize(publicKey) // Validate block size.. for RSA - 11, AES + 16.
        
        var error: Unmanaged<CFError>?
        guard let cipherData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
            if let error = error?.takeUnretainedValue() {
                throw error as Error
            }
            throw CryptographyError(code: -1, description: "Unable to encrypt data")
        }
        
        return cipherData
    }
    
    /// Decrypts data using ECSECPrimeRandom-256-bit SHA512-AES-GCM algorithm and returns the result.
    /// If SHA512-AES-GCM is not supported, falls back to SHA256-AES-GCM.
    public func decrypt(_ data: Data) throws -> Data {
        var existingKey = try getKey()
        if existingKey == nil {
            existingKey = try generateKey()
        }
        
        guard let pKey = existingKey else {
            throw CryptographyError(code: -1, description: "Unable to get secure enclave keys")
        }
        
        var algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA512AESGCM
        if #available(iOS 11.0, *) {
            algorithm = .eciesEncryptionCofactorVariableIVX963SHA512AESGCM
        }
        
        if !SecKeyIsAlgorithmSupported(pKey, .decrypt, algorithm) {
            if #available(iOS 11.0, *) {
                algorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            } else {
                algorithm = .eciesEncryptionCofactorX963SHA256AESGCM
            }
            
            guard SecKeyIsAlgorithmSupported(pKey, .decrypt, algorithm) else {
                throw CryptographyError(code: -1, description: "Encryption Algorithm not supported")
            }
        }
        
        var error: Unmanaged<CFError>?
        guard let clearData = SecKeyCreateDecryptedData(pKey, algorithm, data as CFData, &error) as Data? else {
            if let error = error?.takeUnretainedValue() {
                throw error as Error
            }
            throw CryptographyError(code: -1, description: "Unable to decrypt data")
        }
        
        return clearData
    }
    
    /// Removes the Keys from the secure-enclave and keychain.
    @discardableResult
    public func deleteKeys() -> Error? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag.data(using: .utf8)!,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnRef: kCFBooleanTrue
        ]
        
        let error = SecItemDelete(query as CFDictionary)
        
        if error == errSecSuccess || error == errSecItemNotFound {
            return nil
        }
        
        return CryptographyError(code: error)
    }
    
    /// Generates a new key using ECSECPrimeRandom-256 on the SecureEnclave and stores it in the keychain.
    private func generateKey() throws -> SecKey {
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     .privateKeyUsage,
                                                     nil)!
        
        guard let key = try Cryptography.generateKey(id: tag, type: .ecsecPrimeRandom, bits: 256, storeInKeychain: true, deleteExisting: false, secureEnclave: true, controlFlags: access) else {
            throw CryptographyError(code: -1, description: "Unable to generate Secure Enclave Key")
        }
        return key
    }
    
    /// Retrieves an existing key from the secure-enclave & keychain.
    /// Returns nil on failure.
    private func getKey() throws -> SecKey? {
        return try Cryptography.getPrivateKey(id: tag)
    }
}

extension KeychainCryptography {
    /// Encrypts a given string using ECSECPrimeRandom-256-bit SHA512-AES-GCM algorithm and returns the base-64 encoded result.
    /// If SHA512-AES-GCM is not supported, falls back to SHA256-AES-GCM.
    /// Returns nil on failure.
    public func encrypt(_ string: String) throws -> String? {
        if let data = string.data(using: .utf8) {
            return try? encrypt(data).base64EncodedString()
        }
        return nil
    }
    
    /// Decrypts a string using ECSECPrimeRandom-256-bit SHA512-AES-GCM algorithm and returns the base-64 decoded result.
    /// If SHA512-AES-GCM is not supported, falls back to SHA256-AES-GCM.
    /// Returns nil on failure.
    public func decrypt(_ string: String) throws -> String? {
        if let data = Data(base64Encoded: string) {
            if let data = try? decrypt(data) {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}
