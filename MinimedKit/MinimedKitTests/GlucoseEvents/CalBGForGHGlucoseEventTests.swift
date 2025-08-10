@testable import MinimedKit
import XCTest

class CalBGForGHGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "0e4f5b138fa0")!
        let subject = CalBGForGHGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        let expectedTimestamp = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: 2015,
            month: 5,
            day: 19,
            hour: 15,
            minute: 27
        )
        XCTAssertEqual(subject.timestamp, expectedTimestamp)
        XCTAssertEqual(subject.amount, 160)
        XCTAssertEqual(subject.dictionaryRepresentation["originType"] as! String, "rf")
    }
}
