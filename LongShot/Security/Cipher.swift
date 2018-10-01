//
//  Cipher.swift
//  LongShot
//
//  Created by Brandon on 2018-09-30.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import CommonCrypto

public class Cipher {
    public enum Hash: Int {
        case sha1
        case sha256
        case sha512
    }
    
    public static func secureRandom(_ length: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        if status == errSecSuccess {
            return Data(bytes: bytes)
        }
        
        throw RuntimeError(String(format: "Unable to generate random: %d", status))
    }
    
    public static func hash(_ hash: Hash, data: Data) -> Data {
        let digestLengths = [Int(CC_SHA1_DIGEST_LENGTH), Int(CC_SHA256_DIGEST_LENGTH), Int(CC_SHA512_DIGEST_LENGTH)]
        var bytes = [UInt8](repeating: 0, count: digestLengths[hash.rawValue])
        
        if hash == .sha1 {
            _ = data.withUnsafeBytes {
                CC_SHA1($0, CC_LONG(data.count), &bytes)
            }
        } else if hash == .sha256 {
            _ = data.withUnsafeBytes {
                CC_SHA256($0, CC_LONG(data.count), &bytes)
            }
        } else if hash == .sha512 {
            _ = data.withUnsafeBytes {
                CC_SHA512($0, CC_LONG(data.count), &bytes)
            }
        }
        return Data(bytes: bytes)
    }
    
    public static func HMAC(_ hash: Hash, consumerKey: String, secret: String, timestamp: TimeInterval = Date().timeIntervalSinceNow) -> Data? {
        guard let key = consumerKey.data(using: .utf8),
            let salt = String(format: "%@%.2f", secret, timestamp).data(using: .utf8) else {
                return nil
        }
        
        let digestLengths = [Int(CC_SHA1_DIGEST_LENGTH), Int(CC_SHA256_DIGEST_LENGTH), Int(CC_SHA512_DIGEST_LENGTH)]
        let algorithms = [CCHmacAlgorithm(kCCHmacAlgSHA1), CCHmacAlgorithm(kCCHmacAlgSHA256), CCHmacAlgorithm(kCCHmacAlgSHA512)]
        
        let digestLength = digestLengths[hash.rawValue]
        let algorithm = algorithms[hash.rawValue]
        
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        defer { signature.deallocate() }
        
        salt.withUnsafeBytes { saltBytes in
            key.withUnsafeBytes { keyBytes in
                CCHmac(algorithm, keyBytes, key.count, saltBytes, salt.count, signature)
            }
        }
        
        return Data(bytes: signature, count: digestLength)
            .map { String(format: "%02x", $0) }
            .joined()
            .data(using: .utf8)
    }
}
