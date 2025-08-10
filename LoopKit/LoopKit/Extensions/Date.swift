import Foundation

public extension Date {
    func dateFlooredToTimeInterval(_ interval: TimeInterval) -> Date {
        if interval == 0 {
            return self
        }

        return Date(timeIntervalSinceReferenceDate: floor(timeIntervalSinceReferenceDate / interval) * interval)
    }

    func dateCeiledToTimeInterval(_ interval: TimeInterval) -> Date {
        if interval == 0 {
            return self
        }

        return Date(timeIntervalSinceReferenceDate: ceil(timeIntervalSinceReferenceDate / interval) * interval)
    }
}
