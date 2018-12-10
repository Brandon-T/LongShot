//
//  ResponseWrapper.swift
//  Services
//
//  Created by Brandon on 2018-12-09.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

/// A base wrapper including the Status response and data
public struct ResponseWrapper<T: Decodable>: Decodable {
    /// The data object
    public let data: T
    
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            data = try T(from: decoder)
            return
        }
        
        do {
            data = try container.decode(T.self, forKey: .data)
        } catch {
            data = try T(from: decoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
    }
}

/// A base wrapper including the Status response
public struct ResponseVoidWrapper: Decodable {
}

/// A base wrapper including the Status response
public struct ResponseDataWrapper: Decodable {
    /// The raw data response of the server call
    public let data: Data
}
