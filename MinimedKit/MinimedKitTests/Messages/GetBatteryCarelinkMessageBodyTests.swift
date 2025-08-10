@testable import MinimedKit
import XCTest

class GetBatteryCarelinkMessageBodyTests: XCTestCase {
    func testValidGetBatteryResponse() {
        let message =
            PumpMessage(
                rxData: Data(
                    hexadecimalString: "a7350535720300008c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                )!
            )

        if let message = message {
            XCTAssertTrue(message.messageBody is GetBatteryCarelinkMessageBody)
            let body = message.messageBody as! GetBatteryCarelinkMessageBody
            XCTAssertEqual(body.volts, 1.4)

            if case .normal = body.status {
                // OK
            } else {
                XCTFail()
            }
        } else {
            XCTFail("\(String(describing: message)) is nil")
        }
    }
}
