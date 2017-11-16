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
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap
}

class JSONParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap {
        let json = JSON(data: data)
        if case .null = json.type { return .null }
        return Wrap(json)
    }
}

class TextParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap {
        guard let string = String(data: data, encoding: .utf8) else { return .null }
        return Wrap(string)
    }
}

class QueryParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap {
        guard let query = String(data: data, encoding: .utf8) else { return .null }
        return Query.init(percentEncodedQuery: query)
    }
}

