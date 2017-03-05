//
//  Container+RawBody.swift
//  KituraQuery
//
//  Created by Sergey Minakov on 05.03.17.
//
//

import Foundation
import Query
import Wrap

extension Container {
    
    public struct RawBody {
        var data: Data?
        var type: String?
        var parameters: String?
        
        static let defaultParsers: [Key : RawBodyParserProtocol] = [
            Key(value: "/json", type: .suffix) : JSONParser(),
            Key(value: "text/", type: .prefix) : TextParser(),
            Key(value: "application/x-www-form-urlencoded", type: .equal) : QueryParser(),
            Key(value: "multipart/form-data", type: .prefix) : MultipartParser(),
        ]
        
        public func parse() -> Wrap.Value {
            guard let data = self.data else { return .null }
            guard let type = self.type,
                let parser = RawBody
                    .defaultParsers
                    .first(where: { $0.0.check(for: type) }) else {
                        return Wrap.Value(data)
            }
            
            return parser.value.parse(raw: data, type: type, parameters: self.parameters)
        }
        
        public func parse(using parser: RawBodyParserProtocol) -> Wrap.Value {
            guard let data = self.data else { return .null }
            return parser.parse(raw: data, type: self.type, parameters: self.parameters)
        }
    }
}

extension Container.RawBody {
    
    struct Key {
        
        let value: String
        let type: CheckType
        
        func check(for value: String) -> Bool {
            switch self.type {
            case .prefix:
                return value.hasPrefix(self.value)
            case .suffix:
                return value.hasSuffix(self.value)
            case .equal:
                return value == self.value
            }
        }
    }
}

extension Container.RawBody.Key {
    
    enum CheckType {
        case prefix
        case equal
        case suffix
    }
}

extension Container.RawBody.Key: Hashable {
    
    public var hashValue: Int {
        return self.value.hashValue
    }
    
    public static func ==(lhs: Container.RawBody.Key, rhs: Container.RawBody.Key) -> Bool {
        return lhs.value == rhs.value
            && lhs.type == rhs.type
    }
}
