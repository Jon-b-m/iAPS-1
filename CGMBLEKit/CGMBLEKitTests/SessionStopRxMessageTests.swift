@testable import CGMBLEKit
import XCTest

/// Thanks to https://github.com/mthatcher for the fixtures!
class SessionStopRxMessageTests: XCTestCase {
    func testSuccessfulStop() {
        var data = Data(hexadecimalString: "29000128027200ffffffff47027200ba85")!
        var message = SessionStopRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(1, message.received)
        XCTAssertEqual(7_471_656, message.sessionStopTime)
        XCTAssertEqual(0xFFFF_FFFF, message.sessionStartTime)
        XCTAssertEqual(7_471_687, message.transmitterTime)

        data = Data(hexadecimalString: "2900013ffe7100ffffffffc2fe71008268")!
        message = SessionStopRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(1, message.received)
        XCTAssertEqual(7_470_655, message.sessionStopTime)
        XCTAssertEqual(0xFFFF_FFFF, message.sessionStartTime)
        XCTAssertEqual(7_470_786, message.transmitterTime)

        data = Data(hexadecimalString: "290001f5fb7100ffffffff6afc7100fa8a")!
        message = SessionStopRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(1, message.received)
        XCTAssertEqual(7_470_069, message.sessionStopTime)
        XCTAssertEqual(0xFFFF_FFFF, message.sessionStartTime)
        XCTAssertEqual(7_470_186, message.transmitterTime)
    }
}
