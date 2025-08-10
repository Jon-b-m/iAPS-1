@testable import MinimedKit
import XCTest

class SensorDataHighGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "07FF")!
        let subject = SensorDataHighGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.sgv, 400)
    }
}
