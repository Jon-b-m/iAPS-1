@testable import MinimedKit
import XCTest

class DeviceLinkMessageBodyTests: XCTestCase {
    func testValidDeviceLinkMessage() {
        let message = PumpMessage(rxData: Data(hexadecimalString: "a23505350a93ce8aa000")!)

        if let message = message {
            XCTAssertTrue(message.messageBody is DeviceLinkMessageBody)
        } else {
            XCTFail("\(String(describing: message)) is nil")
        }
    }

    func testMidnightSensor() {
        let message = PumpMessage(rxData: Data(hexadecimalString: "a23505350a93ce8aa000")!)!

        let body = message.messageBody as! DeviceLinkMessageBody

        XCTAssertEqual(body.sequence, 19)
        XCTAssertEqual(body.deviceAddress.hexadecimalString, "ce8aa0")
    }
}
