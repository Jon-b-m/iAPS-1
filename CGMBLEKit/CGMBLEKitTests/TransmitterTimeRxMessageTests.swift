@testable import CGMBLEKit
import XCTest

/// Thanks to https://github.com/mthatcher for the fixtures!
class TransmitterTimeRxMessageTests: XCTestCase {
    func testNoSession() {
        var data = Data(hexadecimalString: "2500e8f87100ffffffff010000000a70")!
        var message = TransmitterTimeRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(7_469_288, message.currentTime)
        XCTAssertEqual(0xFFFF_FFFF, message.sessionStartTime)

        data = Data(hexadecimalString: "250096fd7100ffffffff01000000226d")!
        message = TransmitterTimeRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(7_470_486, message.currentTime)
        XCTAssertEqual(0xFFFF_FFFF, message.sessionStartTime)

        data = Data(hexadecimalString: "2500eeff7100ffffffff010000008952")!
        message = TransmitterTimeRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(7_471_086, message.currentTime)
        XCTAssertEqual(0xFFFF_FFFF, message.sessionStartTime)
    }

    func testInSession() {
        var data = Data(hexadecimalString: "2500470272007cff710001000000fa1d")!
        var message = TransmitterTimeRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(7_471_687, message.currentTime)
        XCTAssertEqual(7_470_972, message.sessionStartTime)

        data = Data(hexadecimalString: "2500beb24d00f22d4d000100000083c0")!
        message = TransmitterTimeRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(5_092_030, message.currentTime)
        XCTAssertEqual(5_058_034, message.sessionStartTime)
    }
}
