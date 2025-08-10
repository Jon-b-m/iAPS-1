import UIKit

public protocol RadioSelectionTableViewControllerDelegate: AnyObject {
    func radioSelectionTableViewControllerDidChangeSelectedIndex(_ controller: RadioSelectionTableViewController)
}

open class RadioSelectionTableViewController: UITableViewController {
    open var options = [String]()

    open var selectedIndex: Int? {
        didSet {
            if let oldValue = oldValue, oldValue != selectedIndex {
                tableView.cellForRow(at: IndexPath(row: oldValue, section: 0))?.accessoryType = .none
            }

            if let selectedIndex = selectedIndex, oldValue != selectedIndex {
                tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0))?.accessoryType = .checkmark

                delegate?.radioSelectionTableViewControllerDidChangeSelectedIndex(self)
            }
        }
    }

    open var contextHelp: String?

    open weak var delegate: RadioSelectionTableViewControllerDelegate?

    public convenience init() {
        self.init(style: .grouped)
    }

    // MARK: - Table view data source

    override open func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override open func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        options.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")

        cell.textLabel?.text = options[indexPath.row]
        cell.accessoryType = selectedIndex == indexPath.row ? .checkmark : .none

        return cell
    }

    override open func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        contextHelp
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
