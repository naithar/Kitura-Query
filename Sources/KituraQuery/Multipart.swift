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

public struct MultipartData {
    
    public internal(set) var name: String
    
    public internal(set) var rawBody: Container.RawBody? {
        didSet {
            guard let rawBody = self.rawBody else { return }
            self.content = rawBody.parse()
        }
    }

    public private(set) var content: Wrap.Value = .null
    
    public var headers = [String : String]()
    
    internal static let empty = MultipartData.init(name: "")
    
    init(name: String, rawBody: Container.RawBody? = nil) {
        self.name = name
        self.rawBody = rawBody
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
        
        var result = MultipartData.empty
        let headerData = partData.subdata(in: 0..<found.lowerBound)
        guard let contentData = self.content(from: partData, range: found, using: boundaryData) else { return nil }
        guard self.process(header: headerData, using: boundaryData, to: &result) else { return nil }
        result.rawBody = Container.RawBody(data: contentData, type: result.headers["content-type"], parameters: nil)
        
        return result
    }
    
    private func content(from partData: Data, range found: Range<Data.Index>, using boundaryData: BoundaryData) -> Data? {
        let finishLength = boundaryData.headerFinish.count
        var length = partData.count - (found.lowerBound + finishLength)
        
        if partData.hasSuffix(boundaryData.newLine) {
            length -= boundaryData.newLine.count
        }
        
        let contentData = partData
            .subdata(in: found.lowerBound + finishLength..<found.lowerBound + finishLength + length)
        
        guard contentData.count > 0 else { return nil }
        
        return contentData
    }
    
    private func process(header headerData: Data,
                         using boundaryData: BoundaryData,
                         to multipartItem: inout MultipartData) -> Bool {
        let headerLines = headerData.components(separatedBy: boundaryData.newLine)
        
        for line in headerLines {
            guard let line = String.init(data: line, encoding: .utf8) else { break }
            self.process(headerLine: line, to: &multipartItem)
        }
        
        return !multipartItem.name.isEmpty
    }
    
    private func process(headerLine line: String, to multipartItem: inout MultipartData) {
        guard !processDisposition(for: line, to: &multipartItem) else { return }
        
        if let labelRange = line.range(ofLabel: "content-type:") {
            multipartItem.headers["content-type"] = line.substring(from: line.index(after: labelRange.upperBound))
            return
        }
    }
    
    private func processDisposition(for line: String, to multipartItem: inout MultipartData) -> Bool {
        if let dispositionRange = line.range(ofLabel: "content-disposition:") {
            let array = ["name", "filename"]
            func process(header: String, to multipartItem: inout MultipartData) {
                if let headerRange = line.range(of: (header + "="),
                                                options: .caseInsensitive,
                                                range: dispositionRange.upperBound..<line.endIndex) {
                    
                    let valueStartIndex = line.index(after: headerRange.upperBound)
                    let valueEndIndex = line.range(of: "\"",
                                                   range: valueStartIndex..<line.endIndex)?.lowerBound ?? line.endIndex
                    let value = line.substring(with: valueStartIndex..<valueEndIndex)
                    
                    multipartItem.headers[header] = value
                }
            }
            
            array.forEach {
                process(header: $0, to: &multipartItem)
                if $0 == "name",
                    let name = multipartItem.headers[$0] {
                    multipartItem.name = name
                }
            }
            
            return true
        }
        
        return false
    }
}
