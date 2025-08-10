import Foundation
import HealthKit
import LoopKit
import SwiftUI

public class DisplayGlucosePreference: ObservableObject {
    @Published public private(set) var unit: HKUnit
    @Published public private(set) var rateUnit: HKUnit
    @Published public private(set) var formatter: QuantityFormatter
    @Published public private(set) var minuteRateFormatter: QuantityFormatter

    public init(displayGlucoseUnit: HKUnit) {
        let rateUnit = displayGlucoseUnit.unitDivided(by: .minute())

        unit = displayGlucoseUnit
        self.rateUnit = rateUnit
        formatter = QuantityFormatter(for: displayGlucoseUnit)
        minuteRateFormatter = QuantityFormatter(for: rateUnit)
        formatter.numberFormatter.notANumberSymbol = "–"
        minuteRateFormatter.numberFormatter.notANumberSymbol = "–"
    }

    /// Formats a glucose HKQuantity and unit as a localized string
    ///
    /// - Parameters:
    ///   - quantity: The quantity
    ///   - includeUnit: Whether or not to include the unit in the returned string
    /// - Returns: A localized string, or the numberFormatter's notANumberSymbol (default is "–")
    open func format(_ quantity: HKQuantity, includeUnit: Bool = true) -> String {
        formatter.string(from: quantity, includeUnit: includeUnit) ?? formatter.numberFormatter.notANumberSymbol
    }

    /// Formats a glucose HKQuantity rate (in terms of mg/dL/min or mmol/L/min and unit as a localized string
    ///
    /// - Parameters:
    ///   - quantity: The quantity
    ///   - includeUnit: Whether or not to include the unit in the returned string
    /// - Returns: A localized string, or the numberFormatter's notANumberSymbol (default is "–")
    open func formatMinuteRate(_ quantity: HKQuantity, includeUnit: Bool = true) -> String {
        minuteRateFormatter.string(from: quantity, includeUnit: includeUnit) ?? formatter.numberFormatter.notANumberSymbol
    }
}

extension DisplayGlucosePreference: DisplayGlucoseUnitObserver {
    public func unitDidChange(to displayGlucoseUnit: HKUnit) {
        unit = displayGlucoseUnit
        formatter = QuantityFormatter(for: displayGlucoseUnit)
    }
}
