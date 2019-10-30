//
//  Multipart.swift
//  KituraQuery
//
//  Created by Sergey Minakov on 05.03.17.
//
//

import Foundation
import SwiftyJSON
import Wrap
import Query

extension CharacterSet {
    
    static let quotes = CharacterSet(charactersIn: "\"")
}

extension String {
    
    static let dashes = "--"
    static let newLine = "\r\n"
    
    func range(ofLabel label: String) -> Range<String.Index>? {
        let options: String.CompareOptions = [.anchored, .caseInsensitive]
        
        return self.range(of: label,
                          options: options,
                          range: self.startIndex..<self.endIndex)
    }
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
        while let found = self.range(of: separator, in: search) {
            parts.append(self.subdata(in: search.lowerBound..<found.lowerBound))
            search = found.upperBound..<self.count
        }
        
        parts.append(self.subdata(in: search))
        return parts
    }
}



class MultipartParser: RawBodyParserProtocol {
    
    typealias BoundaryData = (boundary: Data, newLine: Data, headerFinish: Data, finish: Data)
    
    private static var newLine = String.newLine.data(using: .utf8)
    private static var headerFinish = (String.newLine + String.newLine).data(using: .utf8)
    private static var finish = String.dashes.data(using: .utf8)
    
    
    func parse(raw data: Data, type: String?, parameters: String?) -> Wrap {
        guard let parameters = parameters,
            let boundary = self.boundary(from: parameters),
            let boundaryData = self.boundaryData(using: boundary) else { return .null }
        
        let parts = data.components(separatedBy: boundaryData.boundary)
        
        var result = [String : MultipartItem]()
        var encounteredFinish = false
        
        for part in parts {
            guard !part.hasPrefix(boundaryData.finish) else {
                encounteredFinish = true
                break
            }
            
            if let multipartItem = self.multipartItem(from: part, using: boundaryData) {
                result[multipartItem.name] = multipartItem
            }
        }
        
        guard encounteredFinish else { return .null }
        
        return Wrap(result)
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
            let newLine = MultipartParser.newLine,
            let headerFinish = MultipartParser.headerFinish,
            let finish = MultipartParser.finish else { return nil }
        
        return (boundary, newLine, headerFinish, finish)
    }
    
    private func multipartItem(from partData: Data, using boundaryData: BoundaryData) -> MultipartItem? {
        guard let found = partData.range(of: boundaryData.headerFinish, in: 0..<partData.count) else { return nil }
        
        var result = MultipartItem.empty
        let headerData = partData.subdata(in: 0..<found.lowerBound)
        guard let contentData = self.content(from: partData, range: found, using: boundaryData) else { return nil }
        guard self.process(header: headerData, using: boundaryData, to: &result) else { return nil }
        result.rawBody = RawBody(data: contentData, type: result.headers["content-type"], parameters: nil)
        
        return result
    }
    
    private func content(from partData: Data, range found: Range<Data.Index>, using boundaryData: BoundaryData) -> Data? {
        var length = partData.count - found.upperBound
        
        if partData.hasSuffix(boundaryData.newLine) {
            length -= boundaryData.newLine.count
        }
        
        let contentData = partData
            .subdata(in: found.upperBound..<(found.upperBound + length))
        
        return contentData
    }
    
    private func process(header headerData: Data,
                         using boundaryData: BoundaryData,
                         to multipartItem: inout MultipartItem) -> Bool {
        let headerLines = headerData.components(separatedBy: boundaryData.newLine)
        
        for line in headerLines {
            guard let line = String.init(data: line, encoding: .utf8) else { break }
            self.process(headerLine: line, to: &multipartItem)
        }
        
        if let name = multipartItem.headers["name"] {
            multipartItem.name = name
        }
        
        return !multipartItem.name.isEmpty
    }
    
    private func process(headerLine line: String, to multipartItem: inout MultipartItem) {
        let keyValuePairs = line.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        
        for pair in keyValuePairs {
            let key: String
            let value: String
            
            if let range = pair.range(of: "=") {
                key = pair.substring(to: range.lowerBound)
                value = pair.substring(from: range.upperBound).trimmingCharacters(in: .quotes)
            } else if let range = pair.range(of: ": ") {
                key = pair.substring(to: range.lowerBound)
                value = pair.substring(from: range.upperBound)
            } else {
                continue
            }
            
            multipartItem.headers[key] = value
        }
    }
}
