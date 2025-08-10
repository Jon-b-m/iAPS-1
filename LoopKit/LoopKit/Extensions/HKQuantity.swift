import Foundation
import HealthKit

extension HKQuantity: Comparable {}

public func < (lhs: HKQuantity, rhs: HKQuantity) -> Bool {
    lhs.compare(rhs) == .orderedAscending
}
