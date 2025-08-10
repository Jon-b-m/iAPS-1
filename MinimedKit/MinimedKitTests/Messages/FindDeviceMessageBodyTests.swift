@testable import MinimedKit
import XCTest

class FindDeviceMessageBodyTests: XCTestCase {
    func testValidFindDeviceMessage() {
        let message = PumpMessage(rxData: Data(hexadecimalString: "a235053509cf99999900")!)

        if let message = message {
            XCTAssertTrue(message.messageBody is FindDeviceMessageBody)
        } else {
            XCTFail("\(String(describing: message)) is nil")
        }
    }

    func testMidnightSensor() {
        let message = PumpMessage(rxData: Data(hexadecimalString: "a235053509cf99999900")!)!

        let body = message.messageBody as! FindDeviceMessageBody

        XCTAssertEqual(body.sequence, 79)
        XCTAssertEqual(body.deviceAddress.hexadecimalString, "999999")
    }
}
