import SwiftyJSON
import Kitura
@_exported import Foundation.NSData
@_exported import Query

enum Keys: String {
    case Container = ".Kitura-Query.UserData.Container-Key"
}

public class Container {
    
    public struct Body {
        var data: Data?
        var type: String?
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
    
    public private(set) var rawBody: Body?
    
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

public struct Parser: RouterMiddleware {
    
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard request.body == nil else {
            return next()
        }
        
        guard request.headers["Content-Length"] != nil,
            var contentType = request.headers["Content-Type"] else {
                return next()
        }
        
        if let parameterStart = contentType.range(of: ";") {
            contentType = contentType.substring(to: parameterStart.lowerBound)
        }
        
        let rawData = try BodyParser.readBodyData(with: request)
        let body = Container.Body(data: rawData, type: contentType)
        request.wrap.rawBody = body
        next()
    }
}
