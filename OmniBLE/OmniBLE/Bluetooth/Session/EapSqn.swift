import Foundation

enum EapSqnError: Error {
    case InvalidSize
}

class EapSqn {
    private let SIZE = 6
    let data: Data

    init(data: Data) throws {
        guard data.count == SIZE else { throw EapSqnError.InvalidSize }
        self.data = data
    }

    init(int: Int) {
        data = withUnsafeBytes(of: int.bigEndian) { Data($0) }
    }

    func toInt() -> Int {
        (Data([0x00, 0x00]) + data).withUnsafeBytes {
            $0.load(as: Int.self).bigEndian
        }
    }

    func increment() -> EapSqn {
        EapSqn(int: toInt() + 1)
    }
}
