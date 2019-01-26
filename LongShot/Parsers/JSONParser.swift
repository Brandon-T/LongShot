//
//  JSONParser.swift
//  LongShot
//
//  Created by Brandon on 2019-01-07.
//  Copyright © 2019 XIO. All rights reserved.
//

import Foundation

public struct JSONError: Error {
    let message: String
    
    internal init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
    
    internal static func raise(_ reason: String) {
        NSException(name: NSExceptionName(rawValue: "JSONError"), reason: reason, userInfo: nil).raise()
    }
}

// MARK: - Public
public struct JSON {
    public static func parse(_ string: String) throws -> Any {
        return try JSONParser.parse(string: string)
    }
    
    public static func toString(_ json: Any) throws -> String {
        return try JSONParser.toString(json: json)
    }
}

// MARK: - Private
private class JSONLexer {
    private(set) var tokens = [Token]()
    
    internal init(string: String) throws {
        var json = string
        while !json.isEmpty {
            //Parse String
            var result = try lexString(string: json)
            if let token = result.token {
                json = result.json
                tokens.append(token)
                continue
            }
            
            //Parse Number
            result = try lexNumber(string: json)
            if let token = result.token {
                json = result.json
                tokens.append(token)
                continue
            }
            
            //Parse Bool
            result = try lexBool(string: json)
            if let token = result.token {
                json = result.json
                tokens.append(token)
                continue
            }
            
            //Parse Null
            result = try lexNull(string: json)
            if let token = result.token {
                json = result.json
                tokens.append(token)
                continue
            }
            
            let whitespace = [" ", "\t", "\u{8}", "\n", "\r"]  /// \u{8} = "\b".. OR String(UnicodeScalar(8))
            let syntax = [",": Token.comma,
                          ":": Token.colon,
                          "[": Token.leftBracket,
                          "]": Token.rightBracket,
                          "{": Token.leftBrace,
                          "}": Token.rightBrace]
            
            let token = String(json[json.startIndex])
            if whitespace.contains(token) {
                let lowerBound = json.index(json.startIndex, offsetBy: 1)
                let upperBound = json.endIndex
                json = String(json[lowerBound..<upperBound])
                continue
            } else if syntax.keys.contains(token) {
                tokens.append(syntax[token]!)
                
                let lowerBound = json.index(json.startIndex, offsetBy: 1)
                let upperBound = json.endIndex
                json = String(json[lowerBound..<upperBound])
                continue
            }
            
            throw JSONError("Unexpected Character: \(json[json.startIndex])")
        }
    }
    
    private func lexString(string: String) throws -> (json: String, token: Token?) {
        var jsonString = ""
        if string.first == "\"" {
            for c in String(string.dropFirst()) {
                if c == "\"" {
                    let lowerBound = string.index(string.startIndex, offsetBy: jsonString.count + 2)
                    let upperBound = string.endIndex
                    return (String(string[lowerBound..<upperBound]), .string(jsonString))
                }
                jsonString += String(c)
            }
            
            throw JSONError("Expected Quote: \"")
        }
        return (string, nil)
    }
    
    private func lexNumber(string: String) throws -> (json: String, token: Token?) {
        var jsonNumber = ""
        let validCharacters = (0...9).map({ String($0) }) + ["-", ".", "e"]
        
        for c in string {
            if validCharacters.contains(String(c)) {
                jsonNumber += String(c)
                continue
            }
            break
        }
        
        if !jsonNumber.isEmpty {
            let lowerBound = string.index(string.startIndex, offsetBy: jsonNumber.count)
            let upperBound = string.endIndex
            let rest = String(string[lowerBound..<upperBound])
            
            if jsonNumber.contains(".") || jsonNumber.contains("e") {
                if let float = Float(jsonNumber) {
                    return (rest, .float(float))
                }
                
                if let double = Double(jsonNumber) {
                    return (rest, .double(double))
                }
                return (rest, nil)
            }
            
            if let int = Int(jsonNumber) {
                return (rest, .int(int))
            }
            return (rest, nil)
        }
        
        return (string, nil)
    }
    
    private func lexBool(string: String) throws -> (json: String, token: Token?) {
        let length = string.count
        let trueLength = "true".count
        let falseLength = "false".count
        
        if length >= trueLength {
            let lowerBound = string.startIndex
            let upperBound = string.index(string.startIndex, offsetBy: trueLength)
            let substring = string[lowerBound..<upperBound]
            if substring == "true" {
                return (String(string[upperBound..<string.endIndex]), .bool(true))
            }
        }
        
        if length >= falseLength {
            let lowerBound = string.startIndex
            let upperBound = string.index(string.startIndex, offsetBy: falseLength)
            let substring = string[lowerBound..<upperBound]
            if substring == "false" {
                return (String(string[upperBound..<string.endIndex]), .bool(false))
            }
        }
        
        return (string, nil)
    }
    
    private func lexNull(string: String) throws -> (json: String, token: Token?) {
        let length = string.count
        let nullLength = "null".count
        
        if length >= nullLength {
            let lowerBound = string.startIndex
            let upperBound = string.index(string.startIndex, offsetBy: nullLength)
            let substring = string[lowerBound..<upperBound]
            if substring == "null" {
                return (String(string[upperBound..<string.endIndex]), .null)
            }
        }
        return (string, nil)
    }
    
    internal enum Token {
        //Tokens
        case string(String)
        case int(Int)
        case float(Float)
        case double(Double)
        case bool(Bool)
        case null
        
        //Syntax
        case comma
        case colon
        case leftBracket
        case leftBrace
        case rightBracket
        case rightBrace
        
        func getPrimitive() throws -> Any {
            switch self {
            case .string(let string):
                return string
            case .int(let int):
                return int
            case .float(let float):
                return float
            case .double(let double):
                return double
            case .bool(let bool):
                return bool
            case .null:
                return Optional<Any>.none as Any
            default:
                throw JSONError("Invalid Primitive Type: \(self)")
            }
        }
    }
}

extension JSONLexer.Token: Equatable {
    private static func == (lhs: JSONLexer.Token, rhs: JSONLexer.Token) -> Bool {
        switch (lhs, rhs) {
        case (.string, .string):
            return true
        case (.int, .int):
            return true
        case (.float, .float):
            return true
        case (.double, .double):
            return true
        case (.bool, .bool):
            return true
        case (.null, .null):
            return true
        case (.comma, .comma):
            return true
        case (.colon, .colon):
            return true
        case (.leftBracket, .leftBracket):
            return true
        case (.leftBrace, .leftBrace):
            return true
        case (.rightBracket, .rightBracket):
            return true
        case (.rightBrace, .rightBrace):
            return true
            
        default:
            return false
        }
    }
}

private class JSONParser {
    private let lexer: JSONLexer
    
    private init(string: String) throws {
        self.lexer = try JSONLexer(string: string)
    }
    
    private func parseArray(tokens: [JSONLexer.Token]) throws -> (tokens: [JSONLexer.Token], value: [Any]) {
        var tokens = tokens
        var jsonArray = [Any]()
        
        if tokens[0] == .rightBracket {
            return (Array(tokens.dropFirst()), jsonArray)
        }
        
        while !tokens.isEmpty {
            let result = try parse(tokens: tokens)
            tokens = result.tokens
            jsonArray.append(result.value)
            
            if tokens[0] == .rightBracket {
                return (Array(tokens.dropFirst()), jsonArray)
            }
            
            if tokens[0] == .comma {
                tokens = Array(tokens.dropFirst())
                continue
            }
            
            throw JSONError("Expected Comma Separator in Array Elements")
        }
        
        throw JSONError("Expected Closing Bracket for Array: ]")
    }
    
    private func parseObject(tokens: [JSONLexer.Token]) throws -> (tokens: [JSONLexer.Token], value: [String: Any]) {
        var tokens = tokens
        var jsonObject = [String: Any]()
        
        if tokens[0] == .rightBrace {
            return (Array(tokens.dropFirst()), jsonObject)
        }
        
        while !tokens.isEmpty {
            if case .string(let key) = tokens[0] {
                tokens = Array(tokens.dropFirst())
                
                if tokens[0] != .colon {
                    throw JSONError("Expected Colon.. Got: \(tokens[0])")
                }
                
                let result = try parse(tokens: Array(tokens.dropFirst()))
                tokens = result.tokens
                jsonObject[key] = result.value
                
                if tokens[0] == .rightBrace {
                    return (Array(tokens.dropFirst()), jsonObject)
                }
                
                if tokens[0] == .comma {
                    tokens = Array(tokens.dropFirst())
                    continue
                }
                
                throw JSONError("Expected Comma.. Got: \(tokens[0])")
            }
            
            throw JSONError("Expected String.. Got: \(tokens[0])")
        }
        
        throw JSONError("Expected Closing Bracket for Object: }")
    }
    
    private func parse(tokens: [JSONLexer.Token], isRoot: Bool = false) throws -> (tokens: [JSONLexer.Token], value: Any) {
        
        if isRoot && tokens[0] != .leftBrace {
            throw JSONError("Root must be an object")
        }
        
        if tokens[0] == .leftBracket {
            let result = try parseArray(tokens: Array(tokens.dropFirst()))
            return (result.tokens, result.value)
        }
        
        if tokens[0] == .leftBrace {
            let result = try parseObject(tokens: Array(tokens.dropFirst()))
            return (result.tokens, result.value)
        }
        
        #if DEBUG_TOKENS
        return (Array(tokens.dropFirst()), try tokens[0])
        #else
        return (Array(tokens.dropFirst()), try tokens[0].getPrimitive())
        #endif
    }
    
    // MARK: - Private
    private static func unwrap<T>(_ input: T) -> Any {
        
        let mirror = Mirror(reflecting: input)
        if mirror.displayStyle != .optional {
            return input
        }
        
        if mirror.children.count == 0 { return NSNull() }
        let (_, some) = mirror.children.first!
        return some
    }
    
    private static func isOptional<T>(_ input: T) -> Bool {
        let mirror = Mirror(reflecting: input)
        let style = mirror.displayStyle
        switch style {
        case .some(.optional):
            return true
            
        default:
            return false
        }
    }
}

extension JSONParser {
    static func parse(string: String) throws -> Any {
        let parser = try JSONParser(string: string)
        return try parser.parse(tokens: parser.lexer.tokens, isRoot: false).value
    }
    
    static func toString(json: Any) throws -> String {
        if let dictionary = json as? [String: Any] {
            var string = "{"
            let length = dictionary.count
            for (index, value) in dictionary.enumerated() {
                string += "\"\(value.key)\": \(try toString(json: value.value))"
                string += index < length - 1 ? ", " : "}"
            }
            return string
        }
        
        if let array = json as? [Any] {
            var string = "["
            let length = array.count
            for (index, value) in array.enumerated() {
                string += "\(value)"
                string += index < length - 1 ? ", " : "]"
            }
            return string
        }
        
        if let string = json as? String {
            return "\"\(string)\""
        }
        
        if let bool = json as? Bool {
            return bool ? "true" : "false"
        }
        
        if let int = json as? Int {
            return String(int)
        }
        
        if let float = json as? Float {
            return String(float)
        }
        
        if let double = json as? Double {
            return String(double)
        }
        
        if isOptional(json) {
            return "null"
        }
        
        throw JSONError("Invalid JSON: \(json)")
    }
}

