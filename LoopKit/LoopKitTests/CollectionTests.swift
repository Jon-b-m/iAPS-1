@testable import LoopKit
import XCTest

class CollectionTests: XCTestCase {
    func testChunkedWithEmptyArray() {
        let result = [Int]().chunked(into: 5)
        XCTAssertTrue(result.isEmpty)
    }

    func testChunkedWithArrayEvenMultipleOfChunkSize() {
        let result = [1, 2, 3, 4].chunked(into: 2)
        XCTAssertEqual([[1, 2], [3, 4]], result)
    }

    func testArrayChunkedWithModuloRemainder() {
        let result = [1, 2, 3].chunked(into: 2)
        XCTAssertEqual([[1, 2], [3]], result)
    }
}
