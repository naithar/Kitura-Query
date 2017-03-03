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
import Kitura
import SwiftyJSON

//extension JSON: ParameterValue {
//    
//    public var data: Data? {
//        return try? self.rawData()
//    }
//    
//    public var array: [Any]? {
//        return self.arrayObject
//    }
//    
//    public var dictionary: [String : Any]? {
//        return self.dictionaryObject
//    }
//
//    public subscript(keys: [QueryKeyProtocol]) -> ParameterValue {
//        get {
//            let keys = keys.flatMap { $0.jsonKey }
//            return self[keys]
//        }
//    }
//    
//    public subscript(keys: QueryKeyProtocol...) -> ParameterValue {
//        get {
//            return self[keys]
//        }
//    }
//}
