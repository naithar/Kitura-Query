//
//  MultipartItem+Headers.swift
//  KituraQuery
//
//  Created by Sergey Minakov on 07.03.17.
//
//

import Foundation
import SwiftyJSON
import Wrap
import Query

extension MultipartItem {
    
    public struct Headers {
        
        public typealias Container = [String : String]
        
        fileprivate var container = Container()
    }
}

extension MultipartItem.Headers: Collection {
    
    public typealias HeadersIndex = Container.Index
    
    public var startIndex: HeadersIndex {
        return self.container.startIndex
    }
    
    public var endIndex: HeadersIndex {
        return self.container.endIndex
    }
    
    public subscript(key: String) -> String? {
        get {
            return self.container.first(where: { $0.key.lowercased() == key.lowercased() })?.value
        }
        set {
            self.container[key] = newValue
        }
    }
    
    public subscript(position: HeadersIndex) -> (String, String) {
        return self.container[position]
    }
    
    public func index(after i: HeadersIndex) -> HeadersIndex {
        return self.container.index(after: i)
    }
}
