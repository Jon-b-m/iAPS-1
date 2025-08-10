import XCTest

@testable import LoopKit

class ServiceTests: XCTestCase {
    fileprivate var testService: TestService!

    override func setUp() {
        testService = TestService()
    }

    override func tearDown() {
        testService = nil
    }

    func testServiceIdentifier() {
        XCTAssertEqual(testService.pluginIdentifier, "TestService")
    }

    func testLocalizedTitle() {
        XCTAssertEqual(testService.localizedTitle, "Test Service")
    }
}

private class TestError: Error {}

private class TestService: Service {
    static var pluginIdentifier: String { "TestService" }

    static var localizedTitle: String { "Test Service" }

    public weak var serviceDelegate: ServiceDelegate?

    public weak var stateDelegate: StatefulPluggableDelegate?

    init() {}

    required init?(rawState _: RawStateValue) { nil }

    var rawState: RawStateValue { [:] }

    var isOnboarded = true
}
