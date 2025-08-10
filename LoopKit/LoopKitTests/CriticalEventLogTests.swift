import Foundation
import LoopKit

class MockOutputStream: DataOutputStream {
    var error: Error?
    var data = Data()
    var finished = false

    var streamError: Error? { error }

    func write(_ data: Data) throws {
        if let error = self.error {
            throw error
        }
        self.data.append(data)
    }

    func finish(sync _: Bool) throws {
        if let error = self.error {
            throw error
        }
        finished = true
    }

    var string: String { String(data: data, encoding: .utf8)! }
}
