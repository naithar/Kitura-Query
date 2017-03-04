///
///
///

import Foundation
import Query
import Wrap
import Kitura
import SwiftyJSON

extension WrapKeyProtocol {
    
    public var jsonKey: JSONSubscriptType? {
        return self as? JSONSubscriptType
    }
}

extension JSON: WrapConvertible {

    public var data: Data? {
        return try? self.rawData()
    }

    public var array: [Any]? {
        return self.arrayObject
    }
    
    public var dictionary: [AnyHashable : Any]? {
        guard let dictionary = self.dictionaryObject else { return nil }
        return dictionary as [AnyHashable : Any]
    }
}

extension JSON: WrapSubscriptable {
    
    public subscript(keys: WrapKeyProtocol) -> JSON {
        guard let key = keys.jsonKey else { return JSON.null }
        return self[key]
    }
}

extension JSON: WrapCheckable {
    
    public var isData: Bool {
        return false
    }
    
    public var isBool: Bool {
        switch self.type {
        case .bool:
            return true
        default:
            return false
        }
    }
    
    public var isInt: Bool {
        switch self.type {
        case .number:
            return true
        default:
            return false
        }
    }
    
    public var isDouble: Bool {
        switch self.type {
        case .number:
            return true
        default:
            return false
        }
    }
    
    public var isString: Bool {
        switch self.type {
        case .string:
            return true
        default:
            return false
        }
    }
    
    public var isArray: Bool {
        switch self.type {
        case .array:
            return true
        default:
            return false
        }
    }
    
    public var isDictionary: Bool {
        switch self.type {
        case .dictionary:
            return true
        default:
            return false
        }
    }
    
    public var isNull: Bool {
        switch self.type {
        case .null:
            return true
        default:
            return false
        }
    }
}
