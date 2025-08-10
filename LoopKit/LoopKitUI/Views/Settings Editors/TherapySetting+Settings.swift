import LoopKit
import SwiftUI

public extension TherapySetting {
    var authenticationChallengeDescription: String {
        switch self {
        default:
            // Currently, this is the same no matter what the setting is.
            return LocalizedString(
                "Authenticate to save therapy setting",
                comment: "Authentication hint string for therapy settings"
            )
        }
    }

    @ViewBuilder func helpScreen() -> some View {
        switch self {
        case .glucoseTargetRange:
            CorrectionRangeInformationView(onExit: nil, mode: .settings)
        case .preMealCorrectionRangeOverride:
            CorrectionRangeOverrideInformationView(preset: .preMeal, onExit: nil, mode: .settings)
        case .workoutCorrectionRangeOverride:
            CorrectionRangeOverrideInformationView(preset: .workout, onExit: nil, mode: .settings)
        case .suspendThreshold:
            SuspendThresholdInformationView(onExit: nil, mode: .settings)
        case let .basalRate(maximumScheduleEntryCount):
            BasalRatesInformationView(onExit: nil, mode: .settings, maximumScheduleEntryCount: maximumScheduleEntryCount)
        case .deliveryLimits:
            DeliveryLimitsInformationView(onExit: nil, mode: .settings)
        case .insulinModel:
            InsulinModelInformationView(onExit: nil, mode: .settings)
        case .carbRatio:
            CarbRatioInformationView(onExit: nil, mode: .settings)
        case .insulinSensitivity:
            InsulinSensitivityInformationView(onExit: nil, mode: .settings)
        case .none:
            Text("To be implemented")
        }
    }
}
