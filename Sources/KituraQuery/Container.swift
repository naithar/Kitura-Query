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
    
    private weak var request: RouterRequest?
    
    init(request: RouterRequest) {
        self.request = request
    }
    
    public var parameters: Wrap.Value {
        guard let request = self.request else { return .null }
        return Wrap.Value.init(request.parameters)
    }
    
    public private(set) lazy var query: Query = { [unowned self] in
        guard let request = self.request,
            let query = request.urlURL.query else { return .null }
        return Query.init(percentEncodedQuery: query)
    }()
    
    public private(set) lazy var rawBody: RawBody? = { [unowned self] in
        guard let request = self.request,
            request.body == nil,
            request.headers["Content-Length"] != nil,
            var contentType = request.headers["Content-Type"] else { return nil }
        
        var parameters: String?
        if let parameterStart = contentType.range(of: ";") {
            parameters = contentType.substring(from: parameterStart.upperBound)
            contentType = contentType.substring(to: parameterStart.lowerBound)
            
        }
        
        guard let rawData = try? BodyParser.readBodyData(with: request) else { return nil }
        let body = Container.RawBody(data: rawData, type: contentType, parameters: parameters)
        return body
    }()
    
    public private(set) lazy var body: Wrap.Value = { [unowned self] in
        guard self.request != nil,
            let raw = self.rawBody else { return .null }
        
        return raw.parse()
    }()
}
