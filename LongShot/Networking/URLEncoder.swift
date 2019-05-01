//
//  URLEncoder.swift
//  Services
//
//  Created by Brandon on 2018-12-09.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

#if !canImport(Alamofire)
protocol URLEncoder {
    associatedtype ParamterType
    
    static var `default`: Self { get }
    func encode(_ urlRequest: URLRequest, with parameters: ParamterType?) throws -> URLRequest
}

struct QueryURLEncoder: URLEncoder {
    static var `default`: QueryURLEncoder {
        return QueryURLEncoder()
    }
    
    func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
        var urlRequest = urlRequest
        var urlComponents = URLComponents()
        urlComponents.scheme = urlRequest.url?.scheme
        urlComponents.host = urlRequest.url?.host
        urlComponents.path = urlRequest.url?.path ?? ""
        urlComponents.queryItems = parameters?.map({
            URLQueryItem(name: $0.key, value: $0.value as? String ?? "")
        })
        
        urlRequest.url = urlComponents.url
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = nil
        return urlRequest
    }
}

struct DataURLEncoder: URLEncoder {
    static var `default`: DataURLEncoder {
        return DataURLEncoder()
    }
    
    func encode(_ urlRequest: URLRequest, with parameters: Data?) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = parameters
        return urlRequest
    }
}

struct JSONURLEncoder: URLEncoder {
    static var `default`: JSONURLEncoder {
        return JSONURLEncoder()
    }
    
    func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters ?? [:], options: .prettyPrinted)
        return urlRequest
    }
}
#endif
