//
//  Parser.swift
//  KituraQuery
//
//  Created by Sergey Minakov on 04.03.17.
//
//

import Foundation
import SwiftyJSON
import Wrap
import Query

public protocol RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?) -> Wrap.Value
}

class JSONParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?) -> Wrap.Value {
        let json = JSON(data: data)
        if case .null = json.type { return .null }
        return Wrap.Value(json)
    }
}

class TextParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?) -> Wrap.Value {
        guard let string = String(data: data, encoding: .utf8) else { return .null }
        return Wrap.Value(string)
    }
}

class QueryParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?) -> Wrap.Value {
        guard let query = String(data: data, encoding: .utf8) else { return .null }
        return Query.init(percentEncodedQuery: query)
    }
}

class MultipartParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?) -> Wrap.Value {
        guard let type = type,
            let boundary = self.boundary(from: type) else { return .null }
        
        return .null
    }
    
    func boundary(from type: String) -> String? {
        guard let boundryIndex = type.range(of: "boundary=") else { nil }
        
        var boundary = type
            .substring(from: boundryIndex.upperBound)
            .replacingOccurrences(of: "\"", with: "")

        if let parameterStart = boundary.range(of: ";") {
            boundary = boundary.substring(to: parameterStart.lowerBound)
        }
        
        return boundary
    }
}
