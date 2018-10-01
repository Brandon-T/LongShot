//
//  CertificatePinning.swift
//  LongShot
//
//  Created by Brandon on 2018-09-30.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public class SecureKey {
    
    private var key: SecKey?
    private var base64Key: String = ""
    
    public init(key: SecKey) {
        self.key = key
        
        var error: Unmanaged<CFError>?
        if let data = SecKeyCopyExternalRepresentation(key, &error) {
            self.base64Key = (data as Data).base64EncodedString()
        }
    }
    
    public init(key: String, bits: Int = 256) {
        guard let data = Data(base64Encoded: key) else {
            return
        }
        
        let keyAttributes: [NSObject: NSObject] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: bits),
            kSecReturnPersistentRef: true as NSObject
        ]
        
        guard let publicKey = SecKeyCreateWithData(data as CFData, keyAttributes as CFDictionary, nil) else {
            return
        }
        
        self.key = publicKey
        self.base64Key = key
    }
    
    public init(certificate: SecCertificate) {
        var trust: SecTrust?
        let trustPolicy = SecPolicyCreateBasicX509()
        if SecTrustCreateWithCertificates(certificate, trustPolicy, &trust) == noErr, let trust = trust {
            var result: SecTrustResultType = .invalid
            if SecTrustEvaluate(trust, &result) == noErr {
                if let key = SecTrustCopyPublicKey(trust) {
                    var error: Unmanaged<CFError>?
                    if let data = SecKeyCopyExternalRepresentation(key, &error) {
                        self.base64Key = (data as Data).base64EncodedString()
                    }
                    
                    self.key = key
                }
            }
        }
    }
    
    public init(trust: SecTrust) {
        if let key = SecTrustCopyPublicKey(trust) {
            var error: Unmanaged<CFError>?
            if let data = SecKeyCopyExternalRepresentation(key, &error) {
                self.base64Key = (data as Data).base64EncodedString()
            }
            
            self.key = key
        }
    }
    
    public func toString() -> String {
        return base64Key
    }
    
    public func equals(_ other: SecureKey) -> Bool {
        return self.toString() == other.toString()
    }
}

public class Certificate {
    private var certificate: SecCertificate?
    private var publicKey: SecureKey?
    
    public init(filePath: String) {
        if let data = NSData(contentsOfFile: filePath) {
            if let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data) {
                self.certificate = certificate
                self.publicKey = SecureKey(certificate: certificate)
            }
        }
    }
    
    public init(certificate: SecCertificate) {
        self.certificate = certificate
        self.publicKey = SecureKey(certificate: certificate)
    }
    
    public func toData() -> Data? {
        guard let certificate = self.certificate else { return nil }
        let certificateData = SecCertificateCopyData(certificate)
        let data = CFDataGetBytePtr(certificateData);
        let size = CFDataGetLength(certificateData);
        return NSData(bytes: data, length: size) as Data //OR just cast
    }
    
    public func equals(_ other: Certificate) -> Bool {
        if let data = self.toData(), let otherData = other.toData() {
            return data.elementsEqual(otherData)
        }
        return false
    }
    
    public func isValid(_ challenge: URLAuthenticationChallenge, compareKeys: Bool = true) -> Bool {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secResult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secResult)
                
                if status == errSecSuccess, let localKey = self.publicKey {
                    if compareKeys {
                        if localKey.equals(SecureKey(trust: serverTrust)) {
                            challenge.sender?.use(URLCredential(trust:serverTrust), for: challenge)
//                            challenge.sender?.performDefaultHandling?(for: challenge)
                            return true
                        }
                    } else if let remoteCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        if self.equals(Certificate(certificate: remoteCertificate)) {
                            challenge.sender?.use(URLCredential(trust:serverTrust), for: challenge)
//                            challenge.sender?.performDefaultHandling?(for: challenge)
                            return true
                        }
                    }
                }
            }
        }
        
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
//            //Import PKCS12
//        }
        
        challenge.sender?.cancel(challenge)
        return false
    }
}
