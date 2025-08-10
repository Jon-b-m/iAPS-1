@testable import CGMBLEKit
import XCTest

class TransmitterIDTests: XCTestCase {
    /// Sanity check the hash computation path
    func testComputeHash() {
        let id = TransmitterID(id: "123456")

        XCTAssertEqual("e60d4a7999b0fbb2", id.computeHash(of: Data(hexadecimalString: "0123456789abcdef")!)!.hexadecimalString)
    }
}
