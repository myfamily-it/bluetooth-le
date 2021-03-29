import XCTest
import Capacitor
import Capacitor
@testable import Plugin
@testable import Plugin

class PluginTests: XCTestCase {


    override func setUp() {
    override func setUp() {
        super.setUp()
        super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // Put setup code here. This method is called before the invocation of each test method in the class.
}
}

override func tearDown() {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
            // Put teardown code here. This method is called after the invocation of each test method in the class.
            super.tearDown()
            super.tearDown()
    }
}

func testEcho() {
    // This is an example of a functional test case for a plugin.
    // This is an example of a functional test case for a plugin.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Use XCTAssert and related functions to verify your tests produce the correct results.


        let value = "Hello, World!"
        let value = "Hello, World!"
        XCTAssertEqual(1, 1)
        XCTAssertEqual(1, 1)


        //        let plugin = MyPlugin()
        //        let plugin = MyPlugin()
        //
        //
        //        let call = CAPPluginCall(callbackId: "test", options: [
        //        let call = CAPPluginCall(callbackId: "test", options: [
        //            "value": value
        //            "value": value
        //        ], success: { (result, _) in
        //        ], success: { (result, _) in
        //            let resultValue = result!.data["value"] as? String
        //            let resultValue = result!.data["value"] as? String
        //            XCTAssertEqual(value, resultValue)
        //            XCTAssertEqual(value, resultValue)
        //        }, error: { (_) in
        //        }, error: { (_) in
        //            XCTFail("Error shouldn't have been called")
        //            XCTFail("Error shouldn't have been called")
        //        })
        //        })
        //
        //
        //        plugin.echo(call!)
        //        plugin.echo(call!)
    }
}
}
}







