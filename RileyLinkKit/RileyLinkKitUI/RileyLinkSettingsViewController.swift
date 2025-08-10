import CoreBluetooth
import RileyLinkBLEKit
import RileyLinkKit
import UIKit

open class RileyLinkSettingsViewController: UITableViewController {
    public let devicesDataSource: RileyLinkDevicesTableViewDataSource

    public init(rileyLinkPumpManager: RileyLinkPumpManager, devicesSectionIndex: Int, style: UITableView.Style) {
        devicesDataSource = RileyLinkDevicesTableViewDataSource(
            rileyLinkPumpManager: rileyLinkPumpManager,
            devicesSectionIndex: devicesSectionIndex
        )
        super.init(style: style)
    }

    @available(*, unavailable) public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        devicesDataSource.tableView = tableView
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        devicesDataSource.isScanningEnabled = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        devicesDataSource.isScanningEnabled = false
    }

    // MARK: - UITableViewDataSource

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devicesDataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        devicesDataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        devicesDataSource.tableView(tableView, titleForHeaderInSection: section)
    }

    // MARK: - UITableViewDelegate

    override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        devicesDataSource.tableView(tableView, viewForHeaderInSection: section)
    }
}
