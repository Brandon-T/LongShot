//
//  Endpoint.swift
//  Services
//
//  Created by Brandon on 2018-12-09.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

#if canImport(Alamofire)
import Alamofire
#endif

/// An enum representing the type of HTTP request.
public enum HTTPMethod: String {
    case GET
    case HEAD
    case POST
    case PUT
    case PATCH
    case DELETE
}

/// The type of endpoint query being used. For example, if we want to serialize the request with a JSON body, we use .json..
/// Otherwise we can serialize the request to the query parameters using .query..
/// And .data for raw data serialization.
public enum EndpointParameter {
    case json([String: Any])
    case data(Data)
    case query([String: Any])
    
    var json: [String: Any]? {
        if case let .json(json) = self {
            return json
        }
        return nil
    }
    
    var data: Data? {
        if case let .data(data) = self {
            return data
        }
        return nil
    }
    
    var query: [String: Any]? {
        if case let .query(query) = self {
            return query
        }
        return nil
    }
}

/// The endpoint structure that defines which server endpoint to hit for the request.
public struct Endpoint<T> {
    private(set) public var method: HTTPMethod
    private(set) public var baseURL: String?
    private(set) public var path: String
    private(set) public var parameters: EndpointParameter?
    private(set) public var headers: [String: String]
    private(set) public var shouldHandleCookies: Bool
    
    public init(_ method: HTTPMethod, _ path: String, parameters: EndpointParameter? = nil, headers: [String: String]? = nil, shouldHandleCookies: Bool = true) {
        
        if let url = URL(string: path) {
            self.baseURL = url.scheme?.appending("://").appending(url.host ?? "")
            self.path = url.path
        }
        else {
            self.baseURL = nil
        }
        
        self.method = method
        self.path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? path
        self.parameters = parameters
        self.headers = headers ?? [:]
        self.shouldHandleCookies = shouldHandleCookies
    }
    
    func encode(_ baseURL: String? = nil) throws -> URLRequest? {
        #if canImport(Alamofire)
        guard let baseURL = URL(string: baseURL ?? self.baseURL ?? "") else { return nil }
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        
        request.httpMethod = method.rawValue
        headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key) })
        request.httpShouldHandleCookies = shouldHandleCookies
        
        if let parameters = parameters {
            switch parameters {
            case .json(let json):
                request = try JSONEncoding.default.encode(request, with: json)
                
            case .data(let data):
                request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
                request.httpBody = data
                
            case .query(let query):
                request = try URLEncoding.default.encode(request, with: query)
            }
        }
        
        return request
        #else
        guard let baseURL = URL(string: baseURL ?? self.baseURL ?? "") else { return nil }
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        
        request.httpMethod = method.rawValue
        headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key) })
        request.httpShouldHandleCookies = shouldHandleCookies
        
        if let parameters = parameters {
            switch parameters {
            case .json(let json):
                request = try JSONURLEncoder.default.encode(request, with: json)
                
            case .data(let data):
                request = try DataURLEncoder.default.encode(request, with: data)
                
            case .query(let query):
                request = try QueryURLEncoder.default.encode(request, with: query)
            }
        }
        
        return request
        #endif
    }
    
    //Not necessary but it was when I first wrote this class to act as a coercive function..
    func asDataEndpoint() -> Endpoint<Data> {
        var endpoint = Endpoint<Data>(method, path, parameters: parameters, headers: headers, shouldHandleCookies: shouldHandleCookies)
        endpoint.baseURL = baseURL
        return endpoint
    }
    
    //Not necessary but it was when I first wrote this class to act as a coercive function..
    func asGenericEndpoint<T>() -> Endpoint<T> {
        var endpoint = Endpoint<T>(method, path, parameters: parameters, headers: headers, shouldHandleCookies: shouldHandleCookies)
        endpoint.baseURL = baseURL
        return endpoint
    }
}


