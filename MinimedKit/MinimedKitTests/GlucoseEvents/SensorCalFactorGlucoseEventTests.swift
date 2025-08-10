@testable import MinimedKit
import XCTest

class SensorCalFactorGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "0f4f67130f128c")!
        let subject = SensorCalFactorGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        let expectedTimestamp = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: 2015,
            month: 5,
            day: 19,
            hour: 15,
            minute: 39
        )
        XCTAssertEqual(subject.timestamp, expectedTimestamp)
        XCTAssertEqual(subject.factor, 4.748)
    }
}
