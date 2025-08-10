@testable import MinimedKit
import XCTest

class GetGlucosePageMessageBodyTests: XCTestCase {
    func testTxDataEncoding() {
        let messageBody = GetGlucosePageMessageBody(pageNum: 13)

        XCTAssertEqual(messageBody.txData.subdata(in: 0 ..< 5).hexadecimalString, "040000000d")
    }
}
