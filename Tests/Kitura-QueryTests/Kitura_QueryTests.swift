import XCTest
@testable import Kitura_Query

class Kitura_QueryTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Kitura_Query().text, "Hello, World!")
    }


    static var allTests : [(String, (Kitura_QueryTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
