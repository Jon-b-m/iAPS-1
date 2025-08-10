import CGMBLEKit
import LoopKit
import LoopKitUI
import ShareClient
import UIKit

class TransmitterSetupViewController: UINavigationController, CGMManagerOnboarding, UINavigationControllerDelegate,
    CompletionNotifying
{
    class func instantiateFromStoryboard() -> TransmitterSetupViewController {
        UIStoryboard(name: "TransmitterManagerSetup", bundle: Bundle(for: TransmitterSetupViewController.self))
            .instantiateInitialViewController() as! TransmitterSetupViewController
    }

    weak var cgmManagerOnboardingDelegate: CGMManagerOnboardingDelegate?
    weak var completionDelegate: CompletionDelegate?

    var cgmManagerType: TransmitterManager.Type!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        view.backgroundColor = .systemGroupedBackground
        navigationBar.shadowImage = UIImage()
    }

    func completeSetup(state: TransmitterManagerState) {
        if let manager = cgmManagerType.init(state: state) as? CGMManagerUI {
            cgmManagerOnboardingDelegate?.cgmManagerOnboarding(didCreateCGMManager: manager)
            cgmManagerOnboardingDelegate?.cgmManagerOnboarding(didOnboardCGMManager: manager)
            completionDelegate?.completionNotifyingDidComplete(self)
        }
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated _: Bool
    ) {
        // Read state values
        let viewControllers = navigationController.viewControllers
        let count = navigationController.viewControllers.count

        if count >= 2 {
            switch viewControllers[count - 2] {
            case _ as TransmitterIDSetupViewController:
                break
            default:
                break
            }
        }

        if let setupViewController = viewController as? SetupTableViewController {
            setupViewController.delegate = self
        }

        // Set state values
        switch viewController {
        case _ as TransmitterIDSetupViewController:
            break
        default:
            break
        }

        // Adjust the appearance for the main setup view controllers only
        if viewController is SetupTableViewController {
            navigationBar.isTranslucent = false
            navigationBar.shadowImage = UIImage()
        } else {
            navigationBar.isTranslucent = true
            navigationBar.shadowImage = nil
            viewController.navigationItem.largeTitleDisplayMode = .never
        }
    }

    func navigationController(_: UINavigationController, didShow viewController: UIViewController, animated _: Bool) {
        // Adjust the appearance for the main setup view controllers only
        if viewController is SetupTableViewController {
            navigationBar.isTranslucent = false
            navigationBar.shadowImage = UIImage()
        } else {
            navigationBar.isTranslucent = true
            navigationBar.shadowImage = nil
        }
    }
}

extension TransmitterSetupViewController: SetupTableViewControllerDelegate {
    public func setupTableViewControllerCancelButtonPressed(_: SetupTableViewController) {
        completionDelegate?.completionNotifyingDidComplete(self)
    }
}
