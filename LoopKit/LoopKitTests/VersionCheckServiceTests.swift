@testable import LoopKit
import XCTest

class VersionCheckServiceTests: XCTestCase {
    func testVersionUpdateOrder() throws {
        // Comparable order is important for VersionUpdate.  Do not reorder!
        XCTAssertGreaterThan(VersionUpdate.required, VersionUpdate.recommended)
        XCTAssertGreaterThan(VersionUpdate.recommended, VersionUpdate.available)
        XCTAssertGreaterThan(VersionUpdate.available, VersionUpdate.noUpdateNeeded)
    }
}
