@testable import RileyLinkBLEKit
import XCTest

class ResponseBufferTests: XCTestCase {
    func testSingleError() {
        var buffer = ResponseBuffer<PacketResponse>(endMarker: 0x00)

        buffer.append(Data(hexadecimalString: "bb00")!)

        let responses = buffer.responses

        XCTAssertEqual(1, responses.count)
    }
}
