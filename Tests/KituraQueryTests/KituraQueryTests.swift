import XCTest
@testable import KituraQuery
import SwiftyJSON

class KituraQueryTests: XCTestCase {
    
    func testParameterValueJSON() {
        
        let json = JSON(["a", "b"])
        let wrap = Wrap.Value(json)
        
        XCTAssertEqual(wrap.array as! [String], ["a", "b"])
        XCTAssertNil(wrap.dictionary)
        XCTAssertEqual(wrap[0].string, "a")
        XCTAssertTrue(wrap.isArray)
        
        XCTAssertNotNil(wrap.as([Any].self))
        XCTAssertNotNil(wrap.as([String].self))
//
//        json = JSON(["a" : ["b" : 0]]) as ParameterValue
//        
//        XCTAssertNotNil(json.dictionary)
//        XCTAssertNil(json.array)
//        XCTAssertEqual(json["a", "b"].int, 0)
    }
    
//    func testQueryInRequest() {
//        let router = Router()
//        
//        router.get("/strings") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            XCTAssertNotNil(request.queryParameters["q"])
//            XCTAssertNotNil(request.query["q"].string)
//            XCTAssertEqual(request.query["q"].string, request.queryParameters["q"])
//            
//            response.send(request.query["q"].string ?? "")
//        }
//        
//        router.get("/ints") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            let param = request.queryParameters["q"]
//            XCTAssertNotNil(param)
//            XCTAssertNotNil(request.query["q"].string)
//            let parameterInt = Int(param!)
//            XCTAssertEqual(request.query["q"].int, parameterInt)
//            
//            response.send(request.query["q"].string ?? "")
//        }
//        
//        router.get("/non_int") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            let param = request.queryParameters["q"]
//            XCTAssertNotNil(param)
//            
//            if case .null = request.query["q"].type {
//                XCTFail()
//            }
//            
//            XCTAssertNil(request.query["q"].int)
//            XCTAssertNotNil(request.query["q"].string)
//            XCTAssertEqual(request.query["q"].string, request.queryParameters["q"])
//            
//            response.send(request.query["q"].string ?? "")
//        }
//        
//        router.get("/array") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            XCTAssertNotNil(request.queryParameters["q%5B%5D"] ?? request.queryParameters["q"])
//            
//            if case .null = request.query["q"].type {
//                XCTFail()
//            }
//            
//            XCTAssertNil(request.query["q"].int)
//            XCTAssertNil(request.query["q"].string)
//            XCTAssertNotNil(request.query["q"].array)
//            
//            XCTAssertEqual(request.query["q"][0].int, 1)
//            XCTAssertEqual(request.query["q"][1].int, 2)
//            XCTAssertEqual(request.query["q"][2].int, 3)
//            
//            XCTAssertEqual(request.query["q", 0].int, 1)
//            XCTAssertEqual(request.query["q", 1].int, 2)
//            XCTAssertEqual(request.query["q", 2].int, 3)
//            
//            XCTAssertEqual(request.query["q", 0].int, request.query["q"][0].int)
//            XCTAssertEqual(request.query["q", 1].int, request.query["q"][1].int)
//            XCTAssertEqual(request.query["q", 2].int, request.query["q"][2].int)
//            
//            XCTAssertNil(request.query["q"][3].int)
//            
//            response.send(request.query["q", 0].string ?? "")
//        }
//        
//        router.get("/same_property_array") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            XCTAssertNotNil(request.queryParameters["q"])
//            
//            if case .null = request.query["q"].type {
//                XCTFail()
//            }
//            
//            XCTAssertNil(request.query["q"].int)
//            XCTAssertNil(request.query["q"].string)
//            XCTAssertNotNil(request.query["q"].array)
//            
//            XCTAssertEqual(request.query["q"][0].int, 1)
//            XCTAssertEqual(request.query["q"][1].int, 2)
//            XCTAssertEqual(request.query["q"][2].int, 3)
//            
//            XCTAssertEqual(request.query["q", 0].int, 1)
//            XCTAssertEqual(request.query["q", 1].int, 2)
//            XCTAssertEqual(request.query["q", 2].int, 3)
//            
//            XCTAssertEqual(request.query["q", 0].int, request.query["q"][0].int)
//            XCTAssertEqual(request.query["q", 1].int, request.query["q"][1].int)
//            XCTAssertEqual(request.query["q", 2].int, request.query["q"][2].int)
//            
//            XCTAssertNil(request.query["q"][3].int)
//            
//            response.send(request.query["q", 0].string ?? "")
//        }
//        
//        router.get("/dictionary") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            XCTAssertNotNil(request.queryParameters["q%5Ba%5D"])
//            
//            if case .null = request.query["q"].type {
//                XCTFail()
//            }
//            
//            XCTAssertNil(request.query["q"].int)
//            XCTAssertNil(request.query["q"].string)
//            XCTAssertNil(request.query["q"].array)
//            XCTAssertNotNil(request.query["q"].dictionary)
//            
//            XCTAssertEqual(request.query["q"]["a"].int, 1)
//            XCTAssertEqual(request.query["q"]["str"].string, "done")
//            XCTAssertEqual(request.query["q"]["1"].string, "int")
//            
//            XCTAssertEqual(request.query["q", "a"].int, 1)
//            XCTAssertEqual(request.query["q", "str"].string, "done")
//            XCTAssertEqual(request.query["q", "1"].string, "int")
//            
//            XCTAssertEqual(request.query["q", "a"].int, request.query["q"]["a"].int)
//            XCTAssertEqual(request.query["q", "str"].string, request.query["q"]["str"].string)
//            XCTAssertEqual(request.query["q", "1"].string, request.query["q"]["1"].string)
//            
//            XCTAssertNil(request.query["q"][1].int)
//            XCTAssertNil(request.query["q"]["2"].int)
//            XCTAssertNil(request.query["q"]["a3"].int)
//            
//            response.send(request.query["q", "str"].string ?? "")
//        }
//        
//        router.get("/array_in_dictionary") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            XCTAssertNotNil(request.queryParameters["q%5Ba%5D"])
//            
//            if case .null = request.query["q"].type {
//                XCTFail()
//            }
//            
//            XCTAssertNil(request.query["q"].int)
//            XCTAssertNil(request.query["q"].string)
//            XCTAssertNil(request.query["q"].array)
//            XCTAssertNotNil(request.query["q"].dictionary)
//            
//            XCTAssertNil(request.query["q"]["a"].int)
//            XCTAssertNotNil(request.query["q"]["a"].array)
//            
//            XCTAssertEqual(request.query["q", "a"][0].int, 1)
//            XCTAssertEqual(request.query["q", "a"][1].string, "done")
//            XCTAssertEqual(request.query["q", "a"][2].string, "int")
//            
//            XCTAssertEqual(request.query["q", "b"].int, 10)
//            
//            response.send(request.query["q", "b"].string ?? "")
//        }
//        
//        router.get("/dictionary_in_array") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            XCTAssertNotNil(request.queryParameters["q"])
//            
//            if case .null = request.query["q"].type {
//                XCTFail()
//            }
//            
//            XCTAssertNil(request.query["q"].int)
//            XCTAssertNil(request.query["q"].string)
//            XCTAssertNotNil(request.query["q"].array)
//            
//            XCTAssertNotNil(request.query["q"][0].int)
//            XCTAssertNotNil(request.query["q"][1].int)
//            
//            XCTAssertEqual(request.query["q"][0].int, 1)
//            XCTAssertEqual(request.query["q"][1].int, 2)
//            
//            XCTAssertEqual(request.query["q", 2, "a"][0].string, "done")
//            XCTAssertEqual(request.query["q", 2, "a"][1].string, "int")
//            
//            XCTAssertEqual(request.query["q", 2, "b"].int, 10)
//            
//            response.send(request.query["q", 2, "b"].string ?? "")
//        }
//        
//        performServerTest(router, asyncTasks: { expectation in
//            self.performRequest("get", path: "/strings?q=tra-ta-ta".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "tra-ta-ta")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/ints?q=1050".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "1050")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/non_int?q=105ess0".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "105ess0")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/array?q[]=1&q[]=2&q[]=3".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "1")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/array?q=1,2,3".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "1")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/same_property_array?q=1&q=2&q=3".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "1")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/dictionary?q[a]=1&q[str]=done&q[1]=int".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "done")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/array_in_dictionary?q[a]=1&q[a]=done&q[a]=int&q[b]=10".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "10")
//                
//                expectation.fulfill()
//            })
//        }, { expectation in
//            self.performRequest("get", path: "/dictionary_in_array?q=1,2&q[a]=done&q[a]=int&q[b]=10".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "10")
//                
//                expectation.fulfill()
//            })
//        })
//    }
//    
//    func testQueriableBody() {
//        let router = Router()
//        
//        router.post("*", middleware: BodyParser())
//        
//        router.post("/text") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            guard let body = request.body else {
//                XCTFail("body should exist")
//                return
//            }
//            
//            guard case .text(let string) = body else {
//                XCTFail("wrong body")
//                return
//            }
//            
//            XCTAssertNotNil(body.string)
//            XCTAssertEqual(body.string, "hello")
//            XCTAssertEqual(body.string, string)
//            
//            response.send(body.string ?? "")
//        }
//        
//        router.post("/json") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            guard let body = request.body else {
//                XCTFail("body should exist")
//                return
//            }
//            
//            guard case .json(let json) = body else {
//                XCTFail("wrong body")
//                return
//            }
//            
//            XCTAssertNotNil(body["foo"].string)
//            XCTAssertEqual(body["foo"].string, "bar")
//            XCTAssertEqual(body["foo"].string, json["foo"].stringValue)  // can't use json["foo"].string because of: Ambiguous use of 'subscript'
//            XCTAssertEqual(body["foo"].string, (json["foo"] as JSON).string) //workaround for 'json["foo"].string'
//            XCTAssertEqual(body["inner", "a"].string, (json["inner", "a"] as JSON).string)
//            
//            XCTAssertEqual(body["number"].int, 10)
//            XCTAssertEqual(body["number"].double, 10.0)
//            
//            XCTAssertEqual(body["boolean"].bool, true)
//            
//            XCTAssertNil(body.array)
//            XCTAssertNotNil(body.dictionary)
//            XCTAssertEqual(body.dictionary?.count, 4)
//            
//            response.send(body["foo"].string ?? "")
//        }
//        
//        router.post("/multipart") { request, response, next in
//            defer {
//                response.status(.OK)
//                next()
//            }
//            
//            guard let body = request.body else {
//                XCTFail("body should exist")
//                return
//            }
//            
//            guard case .multipart(let parts) = body else {
//                XCTFail("wrong body")
//                return
//            }
//            
//            guard let parsedBody = (body["text"].object as? Part)?.body,
//                case .text = parsedBody else {
//                    XCTFail("wrong part body")
//                    return
//            }
//            
//            XCTAssertNotNil(body["text"].data)
//            XCTAssertEqual(body["text"].data, "text default".data(using: .utf8))
//            XCTAssertNotNil(body["text"].string)
//            XCTAssertEqual(body["text"].string, "text default")
//            
//            guard let text = parts.first,
//                case .text(let string) = text.body else {
//                    XCTFail()
//                    return
//            }
//            
//            XCTAssertEqual(body["text"].string, string)
//            
//            XCTAssertEqual(body["number"].int, 10)
//            XCTAssertEqual(body["number"].double, 10.0)
//            
//            XCTAssertEqual(body["boolean"].bool, true)
//            
//            XCTAssertNil(body["text"].array)
//            XCTAssertNil(body["text"].dictionary)
//            
//            response.send(body["text"].string ?? "")
//        }
//        
//        
//        performServerTest(router, asyncTasks: { expectation in
//            self.performRequest("post", path: "/text", callback: {response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "hello")
//                
//                expectation.fulfill()
//            }) { req in
//                req.write(from: "hello")
//            }
//        }, { expectation in
//            let jsonToTest = JSON(["foo": "bar", "inner" : ["a" : "b"], "number" : 10, "boolean" : true])
//            
//            self.performRequest("post", path: "/json", callback: {response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "bar")
//                
//                expectation.fulfill()
//            }, headers: ["Content-Type": "application/json"]) { req in
//                do {
//                    let jsonData = try jsonToTest.rawData()
//                    req.write(from: jsonData)
//                    req.write(from: "\n")
//                } catch {
//                    XCTFail("caught error \(error)")
//                }
//            }
//        }, { expectation in
//            
//            self.performRequest("post", path: "/multipart", callback: {response in
//                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
//                
//                let string = try! response!.readString()
//                
//                XCTAssertNotNil(string)
//                XCTAssertEqual(string, "text default")
//                
//                expectation.fulfill()
//            }) {req in
//                req.headers["Content-Type"] = "multipart/form-data; boundary=---------------------------9051914041544843365972754266"
//                req.write(from: "-----------------------------9051914041544843365972754266\r\n" +
//                    "Content-Disposition: form-data; name=\"text\"\r\n\r\n" +
//                    "text default\r\n" +
//                    "-----------------------------9051914041544843365972754266\r\n" +
//                    "Content-Disposition: form-data; name=\"number\"\r\n\r\n" +
//                    "10\r\n" +
//                    "-----------------------------9051914041544843365972754266\r\n" +
//                    "Content-Disposition: form-data; name=\"boolean\"\r\n\r\n" +
//                    "true\r\n" +
//                    "-----------------------------9051914041544843365972754266--")
//            }
//        })
//        
//    }


    static var allTests : [(String, (KituraQueryTests) -> () throws -> Void)] {
        return [
            ("testParameterValueJSON", testParameterValueJSON),
        ]
    }
}
