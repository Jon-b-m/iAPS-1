@testable import OmniBLE
import XCTest

class PodStateTests: XCTestCase {
    func testErrorResponse() {
        do {
            let errorResponse = try ErrorResponse(encodedData: Data(hexadecimalString: "0603070008019a")!)

            switch errorResponse.errorResponseType {
            case let .nonretryableError(errorCode, faultEventCode, podProgress):
                XCTAssertEqual(7, errorCode)
                XCTAssertEqual(.noFaults, faultEventCode.faultType)
                XCTAssertEqual(.aboveFiftyUnits, podProgress)
            default:
                XCTFail("Unexpected bad nonce response")
            }
        } catch {
            XCTFail("message decoding threw error: \(error)")
        }
    }
}
