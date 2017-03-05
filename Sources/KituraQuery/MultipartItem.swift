//
//  MultipartItem.swift
//  KituraQuery
//
//  Created by Sergey Minakov on 05.03.17.
//
//

import Foundation
import SwiftyJSON
import Wrap
import Query

public struct MultipartItem {
    
    public internal(set) var name: String
    
    public internal(set) var rawBody: RawBody? {
        didSet {
            self.updateContent()
        }
    }
    
    public private(set) var content: Wrap.Value = .null
    
    public var headers = [String : String]()
    
    internal static let empty = MultipartItem.init(name: "")
    
    init(name: String, rawBody: RawBody? = nil) {
        self.name = name
        self.rawBody = rawBody
        self.updateContent()
    }
    
    private mutating func updateContent() {
        guard let rawBody = self.rawBody else { return }
        self.content = rawBody.parse()
    }
}

extension MultipartItem: WrapConvertible {
    
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

extension MultipartItem: WrapCheckable {
    
    public var isData: Bool {
        return self.content.isData
    }
    
    public var isBool: Bool {
        return self.content.isBool
    }

    public var isInt: Bool {
        return self.content.isInt
    }
    
    public var isDouble: Bool {
        return self.content.isDouble
    }
    
    public var isString: Bool {
        return self.content.isString
    }

    public var isArray: Bool {
        return self.content.isArray
    }
    
    public var isDictionary: Bool {
        return self.content.isDictionary
    }

    public var isNull: Bool {
        return self.content.isNull
    }
    
    public func `is`<T>(_ type: T.Type) -> Bool {
        return (self as? T != nil) || self.content.is(T.self)
    }
}
