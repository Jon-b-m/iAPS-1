@testable import CGMBLEKit
import XCTest

class GlucoseRxMessageTests: XCTestCase {
    func testMessageData() {
        let data = Data(hexadecimalString: "3100680a00008a715700cc0006ffc42a")!
        let message = GlucoseRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(2664, message.sequence)
        XCTAssertEqual(5_730_698, message.glucose.timestamp)
        XCTAssertFalse(message.glucose.glucoseIsDisplayOnly)
        XCTAssertEqual(204, message.glucose.glucose)
        XCTAssertEqual(6, message.glucose.state)
        XCTAssertEqual(-1, message.glucose.trend)
    }

    func testNegativeTrend() {
        let data = Data(hexadecimalString: "31006f0a0000be7957007a0006e4818d")!
        let message = GlucoseRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(2671, message.sequence)
        XCTAssertEqual(5_732_798, message.glucose.timestamp)
        XCTAssertFalse(message.glucose.glucoseIsDisplayOnly)
        XCTAssertEqual(122, message.glucose.glucose)
        XCTAssertEqual(6, message.glucose.state)
        XCTAssertEqual(-28, message.glucose.trend)
    }

    func testDisplayOnly() {
        let data = Data(hexadecimalString: "3100700a0000f17a5700584006e3cee9")!
        let message = GlucoseRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(2672, message.sequence)
        XCTAssertEqual(5_733_105, message.glucose.timestamp)
        XCTAssertTrue(message.glucose.glucoseIsDisplayOnly)
        XCTAssertEqual(88, message.glucose.glucose)
        XCTAssertEqual(6, message.glucose.state)
        XCTAssertEqual(-29, message.glucose.trend)
    }

    func testOldTransmitter() {
        let data = Data(hexadecimalString: "3100aa00000095a078008b00060a8b34")!
        let message = GlucoseRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(170, message.sequence)
        XCTAssertEqual(7_905_429, message.glucose.timestamp) // 90 days, status is still OK
        XCTAssertFalse(message.glucose.glucoseIsDisplayOnly)
        XCTAssertEqual(139, message.glucose.glucose)
        XCTAssertEqual(6, message.glucose.state)
        XCTAssertEqual(10, message.glucose.trend)
    }

    func testZeroSequence() {
        let data = Data(hexadecimalString: "3100000000008eb14d00820006f6a038")!
        let message = GlucoseRxMessage(data: data)!

        XCTAssertEqual(0, message.status)
        XCTAssertEqual(0, message.sequence)
        XCTAssertEqual(5_091_726, message.glucose.timestamp)
        XCTAssertFalse(message.glucose.glucoseIsDisplayOnly)
        XCTAssertEqual(130, message.glucose.glucose)
        XCTAssertEqual(6, message.glucose.state)
        XCTAssertEqual(-10, message.glucose.trend)
    }
}
