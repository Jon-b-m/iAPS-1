@testable import OmniBLE
import XCTest

class CRC16Tests: XCTestCase {
    func testComputeCRC16() {
        let input = Data(hexadecimalString: "1f01482a10030e0100")!
        XCTAssertEqual(0x802C, input.crc16())
    }
}
