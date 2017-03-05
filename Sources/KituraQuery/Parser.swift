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

extension String {
    
    static let dashes = "--"
    static let newLine = "\r\n"
}

extension Data {
    
    func hasPrefix(_ data: Data) -> Bool {
        guard data.count <= self.count else { return false }
        return self.subdata(in: 0..<data.count) == data
    }
    
    func components(separatedBy separator: Data) -> [Data] {
        var parts: [Data] = []
        
        var search: Range = 0..<self.count
        while true {
            // search for the next occurence of the separator
            guard let found = self.range(of: separator, in: search) else {
                parts.append(self.subdata(in: search))
                break
            }
            // add a part up to the found location
            parts.append(self.subdata(in: search.lowerBound..<found.lowerBound))
            
            search = found.upperBound..<self.count
        }
        return parts
    }
}

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

public struct MultipartData {
    
    public var name: String
    public var fileName: String?
    public var content: Wrap.Value
    
    init(name: String, content: Wrap.Value, fileName: String? = nil) {
        self.name = name
        self.content = content
        self.fileName = fileName
    }
}

class MultipartParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?) -> Wrap.Value {
        guard let type = type,
            let boundary = self.boundary(from: type),
            let boundaryData = self.boundaryData(using: boundary) else { return .null }
        
        
        //body["name"].as(Part.self) -> Part
        
        //Part -> query, file, text, json
    
        
        //Part["p"] -> query["p"], json["p"]. file -> nil. text -> nil
        
        let parts = data.components(separatedBy: boundaryData.boundary)
        
        var result: [Wrap.Value] = []
        var encounteredFinish = false
        
        for part in parts {
            
            guard !part.hasPrefix(boundaryData.finish) else {
                encounteredFinish = true
                break
            }
            
            if let multipartItem = self.getPart(from: part) {
                result.append(multipartItem)
            }
        }
        
        return encounteredFinish ? Wrap.Value(result) : .null
    }
    
    func boundary(from type: String) -> String? {
        guard let boundryIndex = type.range(of: "boundary=") else { return nil }
        
        var boundary = type
            .substring(from: boundryIndex.upperBound)
            .replacingOccurrences(of: "\"", with: "")

        if let parameterStart = boundary.range(of: ";") {
            boundary = boundary.substring(to: parameterStart.lowerBound)
        }
        
        return boundary
    }
    
    func boundaryData(using boundary: String) -> (boundary: Data, newLine: Data, headerFinish: Data, finish: Data)? {
        guard let boundary = (String.dashes + boundary).data(using: .utf8),
            let newLine = String.newLine.data(using: .utf8),
            let headerFinish = (String.newLine + String.newLine).data(using: .utf8),
            let finish = String.dashes.data(using: .utf8) else { return nil }
        
        return (boundary, newLine, headerFinish, finish)
    }
    
    private func getPart(from partData: Data) -> Wrap.Value? {
        return nil
    }
}
