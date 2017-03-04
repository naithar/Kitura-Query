//
//  Container.swift
//  KituraQuery
//
//  Created by Sergey Minakov on 04.03.17.
//
//

import Foundation
import Wrap
import Query
import Kitura

public class Container {
    
    public struct RawBody {
        var data: Data?
        var type: String?
        
        struct Key: Hashable {
            
            enum CheckType {
                case prefix
                case equal
                case suffix
            }
            
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
            
            public var hashValue: Int {
                return self.value.hashValue
            }
            
            public static func ==(lhs: Key, rhs: Key) -> Bool {
                return lhs.value == rhs.value
                    && lhs.type == rhs.type
            }
        }
        
        static let defaultParsers: [Key : RawBodyParserProtocol] = [
            Key(value: "/json", type: .suffix) : JSONParser(),
            Key(value: "text/", type: .prefix) : TextParser(),
            Key(value: "application/x-www-form-urlencoded", type: .equal) : QueryParser(),
            Key(value: "multipart/form-data", type: .prefix) : MultipartParser(),
            ]
        
        public func parse() -> Wrap.Value {
            guard let data = self.data else { return .null }
            guard let type = self.type,
                let parser = RawBody.defaultParsers.first(where: { $0.0.check(for: type) }) else {
                    return Wrap.Value(data)
            }
            
            return parser.value.parse(raw: data)
        }
        
        public func parse(using parser: RawBodyParserProtocol) -> Wrap.Value {
            guard let data = self.data else { return .null }
            return parser.parse(raw: data)
        }
    }
    
    init(request: RouterRequest) {
        self.request = request
    }
    
    private weak var request: RouterRequest?
    
    public var parameters: Wrap.Value {
        guard let request = self.request else { return .null }
        return Wrap.Value.init(request.parameters)
    }
    
    // Cookies
    
    public private(set) lazy var query: Query = { [unowned self] in
        guard let request = self.request,
            let query = request.urlURL.query else { return .null }
        return Query.init(percentEncodedQuery: query)
    }()
    
    public internal(set) lazy var rawBody: RawBody? = { [unowned self] in
        guard let request = self.request,
            request.body == nil,
            request.headers["Content-Length"] != nil,
            var contentType = request.headers["Content-Type"] else { return nil }
        
        if let parameterStart = contentType.range(of: ";") {
            contentType = contentType.substring(to: parameterStart.lowerBound)
        }
        
        guard let rawData = try? BodyParser.readBodyData(with: request) else { return nil }
        let body = Container.RawBody(data: rawData, type: contentType)
        return body
    }()
    
    public private(set) lazy var body: Wrap.Value = { [unowned self] in
        guard self.request != nil,
            let raw = self.rawBody else { return .null }
        
        return raw.parse()
    }()
    
    //    public var body: Wrap.Value // Body ?
}
