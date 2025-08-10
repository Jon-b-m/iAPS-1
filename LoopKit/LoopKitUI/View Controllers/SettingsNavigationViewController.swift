import HealthKit
import LoopKit
import UIKit

open class SettingsNavigationViewController: UINavigationController, CompletionNotifying {
    open weak var completionDelegate: CompletionDelegate?

    open func notifyComplete() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }
}

open class CGMManagerSettingsNavigationViewController: SettingsNavigationViewController, CGMManagerOnboarding {
    open weak var cgmManagerOnboardingDelegate: CGMManagerOnboardingDelegate?
}

open class PumpManagerSettingsNavigationViewController: SettingsNavigationViewController, PumpManagerOnboarding {
    open weak var pumpManagerOnboardingDelegate: PumpManagerOnboardingDelegate?
}
