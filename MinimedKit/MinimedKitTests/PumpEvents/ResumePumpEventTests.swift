import XCTest

@testable import MinimedKit

class ResumePumpEventTests: XCTestCase {
    func testRemotelyTriggeredFlag() {
        let localResume = ResumePumpEvent(availableData: Data(hexadecimalString: "1f20a4e30e0a13")!, pumpModel: .model523)!
        XCTAssert(!localResume.wasRemotelyTriggered)

        let remoteResume = ResumePumpEvent(availableData: Data(hexadecimalString: "1f209de40e4a13")!, pumpModel: .model523)!
        XCTAssert(remoteResume.wasRemotelyTriggered)
    }
}
