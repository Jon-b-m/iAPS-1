import Foundation

extension UUID {
    var data: Data {
        withUnsafePointer(to: uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
        }
    }
}
