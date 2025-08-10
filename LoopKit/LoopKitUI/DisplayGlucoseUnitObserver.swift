import Foundation
import HealthKit

public protocol DisplayGlucoseUnitObserver {
    func unitDidChange(to displayGlucoseUnit: HKUnit)
}
