import Foundation

protocol DateRelativeQuantity {
    var dateOffset: TimeInterval { get set }
    mutating func shift(by offset: TimeInterval)
}

extension DateRelativeQuantity {
    mutating func shift(by offset: TimeInterval) {
        dateOffset += offset
    }
}
