@testable import MinimedKit
import XCTest

class SensorErrorGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "0501")!
        let subject = SensorErrorGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.dictionaryRepresentation["errorType"] as! String, "end")
    }
}
