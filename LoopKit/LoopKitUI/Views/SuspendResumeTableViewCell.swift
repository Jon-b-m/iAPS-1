import Foundation
import LoopKit

public class SuspendResumeTableViewCell: TextButtonTableViewCell {
    public enum Action {
        case suspend
        case resume
        case inoperable
    }

    public var shownAction: Action {
        switch basalDeliveryState {
        case .active,
             .cancelingTempBasal,
             .initiatingTempBasal,
             .suspending,
             .tempBasal:
            return .suspend
        case .resuming,
             .suspended:
            return .resume
        case .none:
            return .inoperable
        }
    }

    private func updateTextLabel() {
        switch basalDeliveryState {
        case .active,
             .tempBasal:
            textLabel?.text = LocalizedString("Suspend Delivery", comment: "Title text for button to suspend insulin delivery")
        case .suspending:
            textLabel?.text = LocalizedString(
                "Suspending",
                comment: "Title text for button when insulin delivery is in the process of being stopped"
            )
        case .suspended:
            textLabel?.text = LocalizedString("Resume Delivery", comment: "Title text for button to resume insulin delivery")
        case .resuming:
            textLabel?.text = LocalizedString(
                "Resuming",
                comment: "Title text for button when insulin delivery is in the process of being resumed"
            )
        case .initiatingTempBasal:
            textLabel?.text = LocalizedString(
                "Starting Temp Basal",
                comment: "Title text for suspend resume button when temp basal starting"
            )
        case .cancelingTempBasal:
            textLabel?.text = LocalizedString(
                "Canceling Temp Basal",
                comment: "Title text for suspend resume button when temp basal canceling"
            )
        case .none:
            textLabel?.text = LocalizedString(
                "Pump Inoperable",
                comment: "Title text for suspend resume button when the basal delivery state is not set"
            )
        }
    }

    private func updateLoadingState() {
        isLoading = {
            switch self.basalDeliveryState {
            case .cancelingTempBasal,
                 .initiatingTempBasal,
                 .resuming,
                 .suspending:
                return true
            default:
                return false
            }
        }()
        isEnabled = !isLoading
    }

    public var basalDeliveryState: PumpManagerStatus.BasalDeliveryState? = .active(Date()) {
        didSet {
            updateTextLabel()
            updateLoadingState()
        }
    }
}
