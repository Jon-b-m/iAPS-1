import UIKit
import UserNotifications

class ResetViewController: UITableViewController {
    @IBOutlet public var aboutText: UITextView!

    private enum State {
        case empty
        case needsConfiguration
        case configured
        case resetting
        case completed
    }

    private var state: State = .empty {
        didSet {
            guard oldValue != state else {
                return
            }

            lastError = nil
            updateButtonState()
            updateTransmitterIDFieldState()
            updateStatusIndicatorState()

            if state == .completed {
                performSegue(withIdentifier: "CompletionViewController", sender: self)
            }
        }
    }

    @IBOutlet var hairlines: [UIView]!

    @IBOutlet var resetButton: Button!

    @IBOutlet var transmitterIDField: TextField!

    @IBOutlet var spinner: UIActivityIndicatorView!

    @IBOutlet var errorLabel: UILabel!

    @IBOutlet var buttonTopSpace: NSLayoutConstraint!

    private var needsButtonTopSpaceUpdate = true

    private var lastError: Error?

    private lazy var resetManager: ResetManager = {
        let manager = ResetManager()
        manager.delegate = self
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        for hairline in hairlines {
            for constraint in hairline.constraints {
                constraint.constant = 1 / UIScreen.main.scale
            }
        }

        navigationController?.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()

        state = .needsConfiguration

        // Setting this color in code because the nib isn't being applied correctly
        if #available(iOS 13.0, *) {
            aboutText.textColor = .secondaryLabel
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { _, _ in
            //
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        state = .needsConfiguration
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Update the constraint once to fit the height of the screen
        if indexPath.section == tableView.numberOfSections - 1, needsButtonTopSpaceUpdate {
            needsButtonTopSpaceUpdate = false
            let currentValue = buttonTopSpace.constant
            let suggestedValue = max(
                0,
                tableView.bounds.size.height - tableView.contentSize.height - tableView.safeAreaInsets.bottom - tableView
                    .safeAreaInsets.top
            )

            if abs(currentValue - suggestedValue) > .ulpOfOne {
                buttonTopSpace.constant = suggestedValue
            }
        }

        return UITableView.automaticDimension
    }

    override func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool {
        false
    }

    override func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
        nil
    }

    // MARK: - Actions

    @IBAction func performAction(_: Any) {
        switch state {
        case .empty,
             .needsConfiguration:
            // Actions are not allowed
            break
        case .configured:
            // Begin reset
            resetTransmitter(withID: transmitterIDField.text ?? "")
        case .resetting:
            // Cancel pending reset
            resetManager.cancel()
        case .completed:
            // Ignore actions here
            break
        }
    }

    private func resetTransmitter(withID id: String) {
        let controller = UIAlertController(
            title: NSLocalizedString(
                "Are you sure you want to reset this transmitter?",
                comment: "Title of the reset confirmation sheet"
            ),
            message: NSLocalizedString(
                "It will take up to 10 minutes to complete.",
                comment: "Message of the reset confirmation sheet"
            ), preferredStyle: .actionSheet
        )

        controller.addAction(UIAlertAction(
            title: NSLocalizedString("Reset", comment: "Reset button title"),
            style: .destructive,
            handler: { _ in
                self.resetManager.resetTransmitter(withID: id)
            }
        ))

        controller.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Title of button to cancel reset"),
            style: .cancel,
            handler: nil
        ))

        present(controller, animated: true, completion: nil)
    }
}

// MARK: - UI state management

extension ResetViewController {
    private func updateButtonState() {
        switch state {
        case .empty,
             .needsConfiguration:
            resetButton.isEnabled = false
        case .completed,
             .configured,
             .resetting:
            resetButton.isEnabled = true
        }

        switch state {
        case .configured,
             .empty,
             .needsConfiguration:
            resetButton.setTitle(NSLocalizedString("Reset", comment: "Title of button to begin reset"), for: .normal)
            resetButton.tintColor = .red
        case .completed,
             .resetting:
            resetButton.setTitle(NSLocalizedString("Cancel", comment: "Title of button to cancel reset"), for: .normal)
            resetButton.tintColor = .darkGray
        }
    }

    private func updateTransmitterIDFieldState() {
        switch state {
        case .empty,
             .needsConfiguration:
            transmitterIDField.text = ""
            transmitterIDField.isEnabled = true
        case .configured:
            transmitterIDField.isEnabled = true
        case .completed,
             .resetting:
            transmitterIDField.isEnabled = false
        }
    }

    private func updateStatusIndicatorState() {
        switch state {
        case .completed,
             .configured,
             .empty,
             .needsConfiguration:
            spinner.stopAnimating()
            errorLabel.superview?.isHidden = true
        case .resetting:
            spinner.startAnimating()
            if let error = lastError {
                errorLabel.text = String(describing: error)
            }
            errorLabel.superview?.isHidden =
                (lastError == nil)
        }
    }
}

extension ResetViewController: ResetManagerDelegate {
    func resetManager(_: ResetManager, didError error: Error) {
        DispatchQueue.main.async {
            self.lastError = error
            self.updateStatusIndicatorState()
        }
    }

    func resetManager(_ manager: ResetManager, didChangeStateFrom _: ResetManager.State) {
        DispatchQueue.main.async {
            switch manager.state {
            case .initialized:
                self.state = .configured
            case .resetting:
                self.state = .resetting
            case .completed:
                self.state = .completed
            }
        }
    }
}

extension ResetViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
}

extension ResetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let stringRange = Range(range, in: text) else {
            state = .needsConfiguration
            return true
        }

        let newText = text.replacingCharacters(in: stringRange, with: string)

        if newText.count >= 6 {
            if newText.count == 6 {
                textField.text = newText
                textField.resignFirstResponder()
            }

            state = .configured
            return false
        }

        state = .needsConfiguration
        return true
    }
}
