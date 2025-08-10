@testable import CGMBLEKit
import XCTest

class TransmitterVersionRxMessageTests: XCTestCase {
    func testRxMessage() {
        let data = Data(hexadecimalString: "4b0001000011df2900005100037000f00009b6")!
        let message = TransmitterVersionRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual([1, 0, 0, 17], message.firmwareVersion)
    }
}
