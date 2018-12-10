//
//  Endpoint.swift
//  Services
//
//  Created by Brandon on 2018-12-09.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

/// An enum representing the type of HTTP request.
enum HTTPMethod: String {
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
enum EndpointParameter {
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
    var method: HTTPMethod
    var baseURL: String?
    var path: String
    var parameters: EndpointParameter?
    var headers: [String: String]
    var shouldHandleCookies: Bool
    
    init(_ method: HTTPMethod, _ path: String, parameters: EndpointParameter? = nil, headers: [String: String]? = nil, shouldHandleCookies: Bool = true) {
        self.method = method
        self.baseURL = nil
        self.path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? path
        self.parameters = parameters
        self.headers = headers ?? [:]
        self.shouldHandleCookies = shouldHandleCookies
    }
    
    func encode(_ baseURL: String? = nil) throws -> URLRequest? {
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


