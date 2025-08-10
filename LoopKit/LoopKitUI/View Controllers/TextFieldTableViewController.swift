import UIKit

public protocol TextFieldTableViewControllerDelegate: AnyObject {
    func textFieldTableViewControllerDidEndEditing(_ controller: TextFieldTableViewController)

    func textFieldTableViewControllerDidReturn(_ controller: TextFieldTableViewController)
}

open class TextFieldTableViewController: UITableViewController, UITextFieldDelegate {
    private weak var textField: UITextField?

    public var indexPath: IndexPath?

    public var placeholder: String?

    public var unit: String?

    public var value: String? {
        didSet {
            delegate?.textFieldTableViewControllerDidEndEditing(self)
        }
    }

    public var contextHelp: String?

    public var keyboardType = UIKeyboardType.default

    public var autocapitalizationType = UITextAutocapitalizationType.sentences

    open weak var delegate: TextFieldTableViewControllerDelegate?

    public convenience init() {
        self.init(style: .grouped)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(TextFieldTableViewCell.nib(), forCellReuseIdentifier: TextFieldTableViewCell.className)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textField?.becomeFirstResponder()
    }

    // MARK: - UITableViewDataSource

    override open func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        1
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TextFieldTableViewCell.className,
            for: indexPath
        ) as! TextFieldTableViewCell

        textField = cell.textField

        cell.textField.delegate = self
        cell.textField.text = value
        cell.textField.keyboardType = keyboardType
        cell.textField.placeholder = placeholder
        cell.textField.autocapitalizationType = autocapitalizationType
        cell.unitLabel?.text = unit

        return cell
    }

    override open func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        contextHelp
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: 0), let textField = textField {
            if textField.isFirstResponder {
                textField.resignFirstResponder()
            } else {
                textField.becomeFirstResponder()
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITextFieldDelegate

    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        value = textField.text

        return true
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        value = textField.text

        textField.delegate = nil
        delegate?.textFieldTableViewControllerDidReturn(self)

        return false
    }
}
