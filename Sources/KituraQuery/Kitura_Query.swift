import SwiftyJSON
import Query
import Kitura

extension QueryKeyProtocol {
    
    public var jsonKey: JSONSubscriptType? {
        return self as? JSONSubscriptType
    }
}

let KituraQueryUserDataKey = ".KituraQueryUserDataKey"

extension RouterRequest {
    
    public var query: Query {
        guard let query = self.userInfo[KituraQueryUserDataKey] as? Query else {
            let value: Query
            
            if let query = self.urlURL.query {
                value = Query(percentEncodedQuery: query)
            } else {
                value = Query.null
            }
            
            self.userInfo[KituraQueryUserDataKey] = value
            return value
        }
        
        return query
    }
}
