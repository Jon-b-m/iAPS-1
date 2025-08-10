@testable import MinimedKit
import XCTest

class ChangeTimeCarelinMessageBodyTests: XCTestCase {
    func testChangeTime() {
        var components = DateComponents()
        components.calendar = Calendar(identifier: Calendar.Identifier.gregorian)

        components.year = 2017
        components.month = 12
        components.day = 29
        components.hour = 9
        components.minute = 22
        components.second = 59

        let message = PumpMessage(
            packetType: .carelink,
            address: "123456",
            messageType: .changeTime,
            messageBody: ChangeTimeCarelinkMessageBody(dateComponents: components)!
        )

        XCTAssertEqual(
            Data(
                hexadecimalString: "a7123456400709163B07E10C1D000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
            ),
            message.txData
        )
    }
}
