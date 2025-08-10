@testable import MinimedKit
import XCTest

class PumpModelTests: XCTestCase {
    func test523AppendsSquareWaveToHistory() {
        XCTAssertTrue(PumpModel.model523.appendsSquareWaveToHistoryOnStartOfDelivery)
    }

    func test522DoesntAppendSquareWaveToHistory() {
        XCTAssertFalse(PumpModel.model522.appendsSquareWaveToHistoryOnStartOfDelivery)
    }
}
