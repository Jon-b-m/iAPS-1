import Foundation
import XCTest

public typealias JSONDictionary = [String: Any]

public extension XCTestCase {
    var bundle: Bundle {
        Bundle(for: type(of: self))
    }

    func loadFixture<T>(_ resourceName: String) -> T {
        guard let path = bundle.path(forResource: resourceName, ofType: "json") else {
            preconditionFailure("Could not find fixture: \(resourceName)")
        }
        return try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path)), options: []) as! T
    }
}
