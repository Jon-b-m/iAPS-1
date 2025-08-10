@testable import CGMBLEKit
import XCTest

/// Thanks to https://github.com/mthatcher for the fixtures!
class SessionStartRxMessageTests: XCTestCase {
    func testSuccessfulStart() {
        var data = Data(hexadecimalString: "2700014bf871004bf87100e9f8710095d9")!
        var message = SessionStartRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(1, message.received)
        XCTAssertEqual(7_469_131, message.requestedStartTime)
        XCTAssertEqual(7_469_131, message.sessionStartTime)
        XCTAssertEqual(7_469_289, message.transmitterTime)

        data = Data(hexadecimalString: "2700012bfd71002bfd710096fd71000f6a")!
        message = SessionStartRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(1, message.received)
        XCTAssertEqual(7_470_379, message.requestedStartTime)
        XCTAssertEqual(7_470_379, message.sessionStartTime)
        XCTAssertEqual(7_470_486, message.transmitterTime)

        data = Data(hexadecimalString: "2700017cff71007cff7100eeff7100aeed")!
        message = SessionStartRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(1, message.received)
        XCTAssertEqual(7_470_972, message.requestedStartTime)
        XCTAssertEqual(7_470_972, message.sessionStartTime)
        XCTAssertEqual(7_471_086, message.transmitterTime)
    }
}
