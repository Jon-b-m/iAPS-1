import Foundation
import SwiftUI

import LoopKitUI

enum PodLifeState {
    case podActivating
    // Time remaining
    case timeRemaining(timeUntilExpiration: TimeInterval, timeUntilExpirationReminder: TimeInterval)
    // Time since expiry
    case expired
    case podDeactivating
    case noPod

    var progress: Double {
        switch self {
        case let .timeRemaining(timeRemaining, _):
            return max(0, min(1, 1 - (timeRemaining / Pod.nominalPodLife)))
        case .expired:
            return 1
        case .podDeactivating:
            return 1
        case .noPod,
             .podActivating:
            return 0
        }
    }

    func progressColor(guidanceColors: GuidanceColors) -> Color {
        switch self {
        case .expired:
            return guidanceColors.critical
        case let .timeRemaining(_, timeUntilExpirationReminder):
            return timeUntilExpirationReminder <= Pod.timeRemainingWarningThreshold ? guidanceColors.warning : .accentColor
        default:
            return Color.secondary
        }
    }

    func labelColor(using guidanceColors: GuidanceColors) -> Color {
        switch self {
        case .expired:
            return guidanceColors.critical
        default:
            return .secondary
        }
    }

    var localizedLabelText: String {
        switch self {
        case .podActivating:
            return LocalizedString("Unfinished Activation", comment: "Label for pod life state when pod not fully activated")
        case .timeRemaining:
            return LocalizedString("Pod expires in", comment: "Label for pod life state when time remaining")
        case .expired:
            return LocalizedString("Pod expired", comment: "Label for pod life state when within pod expiration window")
        case .podDeactivating:
            return LocalizedString("Unfinished deactivation", comment: "Label for pod life state when pod not fully deactivated")
        case .noPod:
            return LocalizedString("No Pod", comment: "Label for pod life state when no pod paired")
        }
    }

    var nextPodLifecycleAction: DashUIScreen {
        switch self {
        case .noPod,
             .podActivating:
            return .pairAndPrime
        default:
            return .deactivate
        }
    }

    var nextPodLifecycleActionDescription: String {
        switch self {
        case .noPod,
             .podActivating:
            return LocalizedString(
                "Pair Pod",
                comment: "Settings page link description when next lifecycle action is to pair new pod"
            )
        case .podDeactivating:
            return LocalizedString(
                "Finish deactivation",
                comment: "Settings page link description when next lifecycle action is to finish deactivation"
            )
        default:
            return LocalizedString(
                "Replace Pod",
                comment: "Settings page link description when next lifecycle action is to replace pod"
            )
        }
    }

    var nextPodLifecycleActionColor: Color {
        switch self {
        case .noPod,
             .podActivating:
            return .accentColor
        default:
            return .red
        }
    }

    var isActive: Bool {
        switch self {
        case .expired,
             .timeRemaining:
            return true
        default:
            return false
        }
    }

    var allowsPumpManagerRemoval: Bool {
        if case .noPod = self {
            return true
        }
        return false
    }
}
