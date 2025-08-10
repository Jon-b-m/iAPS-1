@testable import MinimedKit
import XCTest

class ReadCurrentGlucosePageMessageBodyTests: XCTestCase {
    func testResponseInitializer() {
        var responseData = Data(hexadecimalString: "0000000D6100100020")!
        responseData.append(contentsOf: [UInt8](repeating: 0, count: 65 - responseData.count))

        let messageBody = ReadCurrentGlucosePageMessageBody(rxData: responseData)!

        XCTAssertEqual(messageBody.pageNum, 3425)
        XCTAssertEqual(messageBody.glucose, 16)
        XCTAssertEqual(messageBody.isig, 32)
    }
}
