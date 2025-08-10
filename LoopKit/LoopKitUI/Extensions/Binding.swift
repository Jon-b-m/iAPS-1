import HealthKit
import SwiftUI

extension Binding where Value == Double {
    func withUnit(_ unit: HKUnit) -> Binding<HKQuantity> {
        Binding<HKQuantity>(
            get: { HKQuantity(unit: unit, doubleValue: self.wrappedValue) },
            set: { self.wrappedValue = $0.doubleValue(for: unit) }
        )
    }
}

extension Binding where Value == HKQuantity {
    func doubleValue(for unit: HKUnit) -> Binding<Double> {
        Binding<Double>(
            get: { self.wrappedValue.doubleValue(for: unit) },
            set: { self.wrappedValue = HKQuantity(unit: unit, doubleValue: $0) }
        )
    }
}
