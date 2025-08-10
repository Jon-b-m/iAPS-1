@testable import CGMBLEKit
import XCTest

class CalibrationDataRxMessageTests: XCTestCase {
    func testMessage() {
        let data = Data(hexadecimalString: "33002b290090012900ae00800050e929001225")!
        XCTAssertNotNil(CalibrationDataRxMessage(data: data))
    }
}
