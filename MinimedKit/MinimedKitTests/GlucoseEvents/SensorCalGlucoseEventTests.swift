@testable import MinimedKit
import XCTest

class SensorCalGlucoseEventTests: XCTestCase {
    func testDecodingMeterBgNow() {
        let rawData = Data(hexadecimalString: "0300")!
        let subject = SensorCalGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.dictionaryRepresentation["calibrationType"] as! String, "meter_bg_now")
    }

    func testDecodingWaiting() {
        let rawData = Data(hexadecimalString: "0301")!
        let subject = SensorCalGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.dictionaryRepresentation["calibrationType"] as! String, "waiting")
    }

    func testDecodingCalError() {
        let rawData = Data(hexadecimalString: "0302")!
        let subject = SensorCalGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.dictionaryRepresentation["calibrationType"] as! String, "cal_error")
    }
}
