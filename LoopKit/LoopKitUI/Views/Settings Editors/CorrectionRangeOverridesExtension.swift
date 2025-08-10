import LoopKit
import SwiftUI

extension CorrectionRangeOverrides.Preset {
    public func icon(
        usingCarbTintColor carbTintColor: Color,
        orGlucoseTintColor glucoseTintColor: Color
    ) -> some View
    {
        switch self {
        case .preMeal:
            return icon(named: "Pre-Meal", tinted: carbTintColor)
        case .workout:
            return icon(named: "workout", tinted: glucoseTintColor)
        }
    }

    private func icon(named name: String, tinted color: Color) -> some View {
        Image(name)
            .renderingMode(.template)
            .foregroundColor(color)
    }
}
