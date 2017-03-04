import SwiftyJSON
import Kitura
@_exported import Foundation.NSData
@_exported import Query

enum Keys: String {
    case Container = ".Kitura-Query.UserData.Container-Key"
}

extension RouterRequest {
    
    public var wrap: Container {
        guard let container = self.userInfo[Keys.Container.rawValue] as? Container else {
            let container = Container(request: self)
            self.userInfo[Keys.Container.rawValue] = container
            return container
        }
        
        return container
    }
}
