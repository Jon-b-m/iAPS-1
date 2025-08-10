@testable import RileyLinkBLEKit
import XCTest

class RadioFirmwareVersionTests: XCTestCase {
    func testVersionParsing() {
        let version = RadioFirmwareVersion(versionString: "subg_rfspy 0.8")!

        XCTAssertEqual([0, 8], version.components)
    }
}
