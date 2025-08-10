import RileyLinkKit
import UIKit

protocol TextFieldTableViewControllerDelegate: AnyObject {
    func textFieldTableViewControllerDidEndEditing(controller: TextFieldTableViewController)
}

class TextFieldTableViewController: UITableViewController, IdentifiableClass, UITextFieldDelegate {
    @IBOutlet var textField: UITextField!

    var indexPath: NSIndexPath?

    var placeholder: String?

    var value: String? {
        didSet {
            delegate?.textFieldTableViewControllerDidEndEditing(self)
        }
    }

    var keyboardType = UIKeyboardType.Default
    var autocapitalizationType = UITextAutocapitalizationType.None

    weak var delegate: TextFieldTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.text = value
        textField.keyboardType = keyboardType
        textField.placeholder = placeholder
        textField.autocapitalizationType = autocapitalizationType
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        textField.becomeFirstResponder()
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        value = textField.text

        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        value = textField.text

        textField.delegate = nil

        navigationController?.popViewControllerAnimated(true)

        return false
    }
}
