@testable import MinimedKit
import XCTest

class DateTimeChangeGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "0c0ad23e0e")!
        let subject = DateTimeChangeGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        let expectedTimestamp = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: 2014,
            month: 3,
            day: 30,
            hour: 10,
            minute: 18
        )
        XCTAssertEqual(subject.timestamp, expectedTimestamp)
    }
}
