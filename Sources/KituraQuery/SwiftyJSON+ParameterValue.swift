/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

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
//
//    public var data: Data? {
//        return try? self.rawData()
//    }
//    
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
