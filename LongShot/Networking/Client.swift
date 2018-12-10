//
//  Client.swift
//  Services
//
//  Created by Brandon on 2018-12-08.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import CommonCrypto

public class Client: NSObject {
    public static var shared = Client()
    private var authenticationMethods = [String: TrustAuthentication]()
    
    /// The queue to execute each request on... Currently not used since I just ported everything to use futures and promises and the queue is decided by the promise/future..
    private var queue = DispatchQueue(label: "com.xio.client.queue", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    
    /// The Session Manager.. We can implement certificate pinning here to prevent MITM attack or implement Basic OAuth authentication here..
    private var sessionManager: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = nil
        configuration.urlCache = nil
        
        self.authenticationMethods = [:]
        
        return URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Tasks
    
    /// Returns a request/promise handler for the specified endpoint and immediately executes a request for this endpoint where T is NOT decodable..
    /// IE: Serializes the response to [String: Any] where Any is not Codable..
    func task<T>(endpoint: Endpoint<T>) -> Request<T>? {
        return try? urlRequest(endpoint: endpoint, { data -> T in
            if let result = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? T {
                return result
            }
            
            throw RuntimeError("Cannot Serialize `Data` as Type: \(String(describing: T.self))")
        })
    }
    
    /// Returns a request/promise handler for the specified endpoint and immediately executes a request for this endpoint where T is decodable..
    /// IE: Serializes the response to some model where the model is Codable..
    func task<T: Decodable>(endpoint: Endpoint<T>) -> Request<T>? {
        return try? urlRequest(endpoint: endpoint, { data -> T in
            return try JSONDecoder().decode(T.self, from: data)
        })
    }

    /// Returns a request/promise handler for the specified endpoint and immediately executes a request for this endpoint where the endpoint returns NOTHING..
    func task(endpoint: Endpoint<Void>) -> Request<Void>? {
        return try? urlRequest(endpoint: endpoint, { data -> Void in
            return Void()
        })
    }

    /// Returns a request/promise handler for the specified endpoint and immediately executes a request for this endpoint where the endpoint returns raw data..
    func task(endpoint: Endpoint<Data>) -> Request<Data>? {
        return try? urlRequest(endpoint: endpoint, { data -> Data in
            return data
        })
    }
}

// MARK: - Requests

extension Client {
    /// Generic request executer which executes a request to an endpoint and providers a serialization block which is used to resolve the future/promise..
    private func urlRequest<T, U>(endpoint: Endpoint<T>, _ serializer: @escaping (Data) throws -> U) throws -> Request<U> {
        
        /// Create a request with the given endpoint..
        guard let request = try endpoint.encode(endpoint.baseURL) else {
            throw RuntimeError("Cannot Create Request with endpoint: \(endpoint)")
        }
        
        /// Create a promise that encapsulates the raw request callback
        var task: URLSessionDataTask!
        let promise = Promise<(data: U, response: URLResponse)>({ [weak self] resolve, reject in
            guard let self = self else { return }
            task = self.sessionManager.dataTask(with: request) { data, response, error in
                /// Reject the request.. Some sort of error has occurred.
                if let error = error {
                    return reject(error)
                }
                
                if let data = data, let response = response {
                    do {
                        /// Ask the external resolver to serialize the data and return it to the promises' resolver.
                        return resolve((try serializer(data), response))
                    } catch {
                        return reject(error)
                    }
                }
                
                /// Reject the request.. We don't know how to handle it.
                return reject(RuntimeError("No Response from the server"))
            }
            
            task.resume()
        })
        
        /// Coercion..
        return Request<U>(endpoint.asGenericEndpoint(), task: task, promise: promise)
    }
}

// MARK: - Security

extension Client: URLSessionDataDelegate {
    
    /// A TrustAuthentication that determines how to handle the server challenge..
    enum TrustAuthentication {
        case pinnedCertificates(_ certificates: SecCertificate)
        case pinnedPublicKeys(_ keys: [SecKey])
        case pinnedCredentials(_ username: String, _ password: String)
    }
    
    /// Handles the server authentication challenge via Basic OAuth OR certificate pinning via certificate OR public key pinning.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        //NO AUTH
        if self.authenticationMethods.isEmpty {
            return completionHandler(.performDefaultHandling, nil)
        }

        //BASIC
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            if challenge.proposedCredential != nil || challenge.previousFailureCount > 0 {
                return completionHandler(.cancelAuthenticationChallenge, nil)
            }
            
            if case let .pinnedCredentials(credentials)? = self.authenticationMethods[challenge.protectionSpace.host] {
                let creds = URLCredential(user: credentials.0, password: credentials.1, persistence: .forSession)
                return completionHandler(.useCredential, creds)
            }
            return completionHandler(.performDefaultHandling, nil)
        }
        
        //PINNING
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            guard let clientAuthentication = self.authenticationMethods[challenge.protectionSpace.host] else { return completionHandler(.performDefaultHandling, nil) }
            
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                
                if status == errSecSuccess {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        if case let .pinnedCertificates(certificate) = clientAuthentication {
                            let serverFingerprint = Client.sha1FingerPrint(data: SecCertificateCopyData(serverCertificate) as Data)
                            let clientFingerprint = Client.sha1FingerPrint(data: SecCertificateCopyData(certificate) as Data)
                            
                            if serverFingerprint == clientFingerprint {
                                return completionHandler(.useCredential, URLCredential(trust: serverTrust))
                            }
                            return completionHandler(.cancelAuthenticationChallenge, nil)
                        }
                        
                        if case let .pinnedPublicKeys(publicKeys) = clientAuthentication {
                            if let serverKey = SecCertificateCopyPublicKey(serverCertificate), let serverPublicKey = (SecKeyCopyExternalRepresentation(serverKey, nil) as Data?)?.base64EncodedString() {
                                
                                for key in publicKeys {
                                    if let localPublicKey = (SecKeyCopyExternalRepresentation(key, nil) as Data?)?.base64EncodedString() {
                                        if localPublicKey == serverPublicKey {
                                            return completionHandler(.useCredential, URLCredential(trust: serverTrust))
                                        }
                                    }
                                }
                            }
                            return completionHandler(.cancelAuthenticationChallenge, nil)
                        }
                    }
                }
            }
            
            return completionHandler(.cancelAuthenticationChallenge, nil)
        }
        
        return completionHandler(.performDefaultHandling, nil)
    }
}

// MARK: - Internal

extension Client {
    /// Retrieves all public keys within the bundle.
    private static func publicKeys(in bundle: Bundle = Bundle.main) -> [SecKey] {
        return certificates(in: bundle).compactMap({ SecCertificateCopyPublicKey($0) })
    }
    
    /// Retrieves all certificates within the bundle.
    private static func certificates(in bundle: Bundle = Bundle.main) -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        let paths = Set([".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].map { fileExtension in
            bundle.paths(forResourcesOfType: fileExtension, inDirectory: nil)
            }.joined())
        
        for path in paths {
            if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData, let certificate = SecCertificateCreateWithData(nil, certificateData) {
                certificates.append(certificate)
            }
        }
        
        return certificates
    }
    
    /// Retrieves a sha1 fingerprint from data (mostly used for certificate data)..
    /// Note that Sha1 is deprecated & broken! but some servers still use it!
    private static func sha1FingerPrint(data: Data) -> String {
        var bytes = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &bytes)
        }
        
        var fingerPrint = String()
        for i in 0..<Int(CC_SHA1_DIGEST_LENGTH) {
            fingerPrint = fingerPrint.appendingFormat("%02x", bytes[i])
        }
        return fingerPrint.trimmingCharacters(in: .whitespaces)
    }
}
