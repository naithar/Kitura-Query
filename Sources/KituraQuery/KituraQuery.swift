import SwiftyJSON
import Kitura
@_exported import Foundation.NSData
@_exported import Query

enum Keys: String {
    case Container = ".Kitura-Query.UserData.Container-Key"
}

public protocol RawBodyParserProtocol {
    
    func parse(raw data: Data) -> Wrap.Value
}

class JSONParser: RawBodyParserProtocol {
    
    func parse(raw data: Data) -> Wrap.Value {
        let json = JSON(data: data)
        
        if case .null = json.type { return .null }
        
        return Wrap.Value(json)
    }
}

class TextParser: RawBodyParserProtocol {
    
    func parse(raw data: Data) -> Wrap.Value {
        guard let string = String(data: data, encoding: .utf8) else { return .null }
        return Wrap.Value(string)
    }
}

class QueryParser: RawBodyParserProtocol {
    
    func parse(raw data: Data) -> Wrap.Value {
        guard let query = String(data: data, encoding: .utf8) else { return .null }
        return Query.init(percentEncodedQuery: query)
    }
}

class MultipartParser: RawBodyParserProtocol {
    
    func parse(raw data: Data) -> Wrap.Value {
        return .null
    }
}

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

extension RouterRequest {
    
    public var wrap: Container {
        guard let container = self.userInfo[Keys.Container.rawValue] as? Container else {
            let container = Container(request: self)
            self.userInfo[Keys.Container.rawValue] = container
            return container
        }
        
        return container
    }
}
