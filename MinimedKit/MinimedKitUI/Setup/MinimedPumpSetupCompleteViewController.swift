import LoopKitUI
import UIKit

class MinimedPumpSetupCompleteViewController: SetupTableViewController {
    @IBOutlet private var pumpImageView: UIImageView!

    var pumpImage: UIImage? {
        didSet {
            if isViewLoaded {
                pumpImageView.image = pumpImage
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pumpImageView.image = pumpImage

        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
    }

    override func continueButtonPressed(_: Any) {
        if let setupViewController = navigationController as? MinimedPumpManagerSetupViewController {
            setupViewController.finishedSetup()
        }
    }
}
