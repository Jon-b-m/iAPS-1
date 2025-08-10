@testable import MinimedKit
import XCTest

class GlucoseSensorDataGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "35")!
        let subject = GlucoseSensorDataGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.sgv, 106)
    }
}
