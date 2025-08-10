import LoopKit
import LoopKitUI
import RileyLinkKit
import UIKit

open class RileyLinkManagerSetupViewController: UINavigationController, PumpManagerOnboarding, UINavigationControllerDelegate,
    CompletionNotifying
{
    open var maxBasalRateUnitsPerHour: Double?

    open var maxBolusUnits: Double?

    open var basalSchedule: BasalRateSchedule?

    open weak var pumpManagerOnboardingDelegate: PumpManagerOnboardingDelegate?

    open weak var completionDelegate: CompletionDelegate?

    open var rileyLinkPumpManager: RileyLinkPumpManager?

    override open func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOSApplicationExtension 13.0, *) {
            // Prevent interactive dismissal
            isModalInPresentation = true
        }

        delegate = self
    }

    open func navigationController(
        _ navigationController: UINavigationController,
        willShow _: UIViewController,
        animated _: Bool
    ) {
        let viewControllers = navigationController.viewControllers
        let count = navigationController.viewControllers.count

        if count >= 2, let setupViewController = viewControllers[count - 2] as? RileyLinkSetupTableViewController {
            rileyLinkPumpManager = setupViewController.rileyLinkPumpManager
        }
    }

    open func finishedSetup() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }
}
