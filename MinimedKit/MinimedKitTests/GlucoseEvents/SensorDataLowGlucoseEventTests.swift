@testable import MinimedKit
import XCTest

class SensorDataLowGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "06")!
        let subject = SensorDataLowGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.sgv, 40)
    }
}
