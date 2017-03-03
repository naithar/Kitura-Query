import SwiftyJSON
import Kitura
@_exported import Foundation.NSData
@_exported import Query


//extension QueryKeyProtocol {
//    
//    public var jsonKey: JSONSubscriptType? {
//        return self as? JSONSubscriptType
//    }
//}


enum Keys: String {
    
    case Query = ".Kitura-Query.UserData.Query-Key"
    case RawBody = ".Kitura-Query.UserData.RawBody-Key"
    case Container = ".Kitura-Query.UserData.Container-Key"
}
//let KituraQueryUserDataKey = ".Kitura-Query.UserData.Key"
//let KituraQueryUserDataKey = ".Kitura-Query.UserData.Key"

public class Container {
    
    
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
    
//    public var body: Wrap.Value // Body ?
}

extension RouterRequest {
    
    internal var rawBody: Data? {
        set {
            self.userInfo[Keys.RawBody.rawValue] = newValue
        }
        get {
            return self.userInfo[Keys.RawBody.rawValue] as? Data
        }
    }
    
    public var container: Container {
        guard let container = self.userInfo[Keys.Container.rawValue] as? Container else {
            let container = Container(request: self)
            self.userInfo[Keys.Container.rawValue] = container
            return container
        }
        
        return container
    }
    
    public var query: Query {
        guard let query = self.userInfo[Keys.Query.rawValue] as? Query else {
            let value: Query
            
            if let query = self.urlURL.query {
                value = Query(percentEncodedQuery: query)
            } else {
                value = Query.null
            }
            
            self.userInfo[Keys.Query.rawValue] = value
            return value
        }
        
        return query
    }
}

public struct Parser: RouterMiddleware {
    
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard request.body == nil else {
            return next()
        }
        
        guard request.headers["Content-Length"] != nil else {
            return next()
        }
        
        request.rawBody = try BodyParser.readBodyData(with: request)
        next()
    }
}
