@testable import MinimedKit
import XCTest

class SensorPacketGlucoseEventTests: XCTestCase {
    func testDecoding() {
        let rawData = Data(hexadecimalString: "0402")!
        let subject = SensorPacketGlucoseEvent(availableData: rawData, relativeTimestamp: DateComponents())!

        XCTAssertEqual(subject.dictionaryRepresentation["packetType"] as! String, "init")
    }
}
