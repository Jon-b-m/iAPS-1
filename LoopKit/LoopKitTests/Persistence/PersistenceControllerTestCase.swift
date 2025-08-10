@testable import LoopKit
import XCTest

class PersistenceControllerTestCase: XCTestCase {
    var cacheStore: PersistenceController!

    override func setUp() {
        super.setUp()

        cacheStore = PersistenceController(
            directoryURL: URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
        )
    }

    override func tearDown() {
        cacheStore.tearDown()
        cacheStore = nil

        super.tearDown()
    }

    deinit {
        cacheStore?.tearDown()
    }
}
