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
    
    func hasSuffix(_ data: Data) -> Bool {
        guard data.count <= self.count else { return false }
        return self.subdata(in: (self.count - data.count)..<self.count) == data
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
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap.Value
}

class JSONParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap.Value {
        let json = JSON(data: data)
        if case .null = json.type { return .null }
        return Wrap.Value(json)
    }
}

class TextParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap.Value {
        guard let string = String(data: data, encoding: .utf8) else { return .null }
        return Wrap.Value(string)
    }
}

class QueryParser: RawBodyParserProtocol {
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap.Value {
        guard let query = String(data: data, encoding: .utf8) else { return .null }
        return Query.init(percentEncodedQuery: query)
    }
}

public struct MultipartData {
    
    public var name: String
    public var fileName: String?
    public var content: Wrap.Value
    
    //parameter name
    //headers
    //content
    
    init(name: String, content: Wrap.Value, fileName: String? = nil) {
        self.name = name
        self.content = content
        self.fileName = fileName
    }
}

extension MultipartData: WrapConvertible {
    
    public var object: Any {
        return self.content.object
    }
    
    public var data: Data? {
        return self.content.data
    }
    
    public var bool: Bool? {
        return self.content.bool
    }
    
    public var int: Int? {
        return self.content.int
    }
    
    public var double: Double? {
        return self.content.double
    }
    
    public var string: String? {
        return self.content.string
    }
    
    public var array: [Any]? {
        return self.content.array
    }
    
    public var dictionary: [AnyHashable : Any]? {
        return self.content.dictionary
    }
    
    public func `as`<T>(_ type: T.Type) -> T? {
        return (self as? T) ?? self.content.as(T.self)
    }
}

class MultipartParser: RawBodyParserProtocol {
    
    typealias BoundaryData = (boundary: Data, newLine: Data, headerFinish: Data, finish: Data)
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap.Value {
        guard let parameters = parameters,
            let boundary = self.boundary(from: parameters),
            let boundaryData = self.boundaryData(using: boundary) else { return .null }
        //body["name"].as(Part.self) -> Part
        
        //Part -> query, file, text, json, data
    
        
        //Part["p"] -> query["p"], json["p"]. file -> nil. text -> nil
        
        let parts = data.components(separatedBy: boundaryData.boundary)
        
        var result = [String : MultipartData]()
        var encounteredFinish = false
        
        for part in parts {
            
            guard !part.hasPrefix(boundaryData.finish) else {
                encounteredFinish = true
                break
            }
            
            if let multipartItem = self.getPart(from: part, using: boundaryData) {
                result[multipartItem.name] = multipartItem
            }
        }
        
        guard encounteredFinish else { return .null }
        
        return Wrap.Value(result)
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
    
    func boundaryData(using boundary: String) -> BoundaryData? {
        guard let boundary = (String.dashes + boundary).data(using: .utf8),
            let newLine = String.newLine.data(using: .utf8),
            let headerFinish = (String.newLine + String.newLine).data(using: .utf8),
            let finish = String.dashes.data(using: .utf8) else { return nil }
        
        return (boundary, newLine, headerFinish, finish)
    }
    
    private func getPart(from partData: Data, using boundaryData: BoundaryData) -> MultipartData? {
        guard let found = partData.range(of: boundaryData.headerFinish, in: 0..<partData.count) else { return nil }
        
        let headerLines = partData
            .subdata(in: 0..<found.lowerBound)
            .components(separatedBy: boundaryData.newLine)
        
        var headers = [String : String]()
        for line in headerLines {
            guard let header = String.init(data: line, encoding: .utf8) else { break }
            self.processHeaderLine(header, to: &headers)
        }
        
        guard let name = headers[".name"] else { return nil }
        
        let finishLength = boundaryData.headerFinish.count
        var length = partData.count - (found.lowerBound + finishLength)
        // if the part ends with a \r\n, we delete it since it is part of the next boundary
        if partData.hasSuffix(boundaryData.newLine) {
            length -= boundaryData.newLine.count
        }
        let contentData = partData
            .subdata(in: found.lowerBound + finishLength..<found.lowerBound + finishLength + length)
        
        guard contentData.count > 0 else { return nil }
        
        let body = Container.RawBody(data: contentData, type: headers[".type"], parameters: nil)
        
        let result = MultipartData(name: name, content: body.parse())
        
        return result
    }
    
    private func processHeaderLine(_ line: String, to dictionary: inout [String : String]) {
        if let nameRange = line.range(of: "name=",
                                        options: .caseInsensitive,
                                        range: line.startIndex..<line.endIndex) {
            
            let valueStartIndex = line.index(after: nameRange.upperBound)
            let valueEndIndex = line.range(of: "\"", range: valueStartIndex..<line.endIndex)
            let name = line.substring(with: valueStartIndex..<(valueEndIndex?.lowerBound ?? line.endIndex))
            
            dictionary[".name"] = name
        }
        
        if let labelRange = getLabelRange(of: "content-type:", in: line) {
//            part.type = line.substring(from: line.index(after: labelRange.upperBound))
            dictionary[".type"] = line
            return
        }
    }
    
    private func getLabelRange(of searchedString: String, in containingString: String) -> Range<String.Index>? {
        let options: String.CompareOptions = [.anchored, .caseInsensitive]
        
        return containingString
            .range(of: searchedString,
                   options: options,
                   range: containingString.startIndex..<containingString.endIndex)
    }
}
