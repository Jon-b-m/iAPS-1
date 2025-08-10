import HealthKit
import LoopKit
import SwiftUI

extension Guardrail where Value == HKQuantity {
    func color(
        for quantity: HKQuantity,
        guidanceColors: GuidanceColors
    ) -> Color
    {
        switch classification(for: quantity) {
        case .withinRecommendedRange:
            return guidanceColors.acceptable
        case let .outsideRecommendedRange(threshold):
            switch threshold {
            case .maximum,
                 .minimum:
                return guidanceColors.critical
            case .aboveRecommended,
                 .belowRecommended:
                return guidanceColors.warning
            }
        }
    }
}
