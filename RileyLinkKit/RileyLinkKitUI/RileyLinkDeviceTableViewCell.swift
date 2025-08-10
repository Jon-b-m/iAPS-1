import CoreBluetooth
import UIKit

public class RileyLinkDeviceTableViewCell: UITableViewCell {
    public var connectSwitch: UISwitch?

    override public init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        // Manually layout the switch with an 8pt left margin
        // TODO: Adjust appropriately for RTL
        let connectSwitch = UISwitch(frame: .zero)
        connectSwitch.sizeToFit()
        connectSwitch.frame = connectSwitch.frame.offsetBy(dx: 8, dy: 0)

        var switchFrame = connectSwitch.frame
        switchFrame.origin = .zero
        switchFrame.size.width += 8

        let switchContainer = UIView(frame: switchFrame)
        switchContainer.addSubview(connectSwitch)

        self.connectSwitch = connectSwitch

        accessoryView = switchContainer
        accessoryType = .disclosureIndicator
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutMargins.left = separatorInset.left
        contentView.layoutMargins.right = separatorInset.left
    }

    public func configureCellWithName(_ name: String?, signal: String?, peripheralState: CBPeripheralState?) {
        textLabel?.text = name
        if peripheralState == .connecting {
            detailTextLabel?.text = "..."
        } else {
            detailTextLabel?.text = " \(signal ?? "") "
        }

        if let state = peripheralState {
            switch state {
            case .connected:
                connectSwitch?.isOn = true
                connectSwitch?.isEnabled = true
            case .connecting:
                connectSwitch?.isOn = true
                connectSwitch?.isEnabled = true
            case .disconnected:
                connectSwitch?.isOn = false
                connectSwitch?.isEnabled = true
            case .disconnecting:
                fallthrough
            @unknown default:
                connectSwitch?.isOn = false
                connectSwitch?.isEnabled = false
            }
        } else {
            connectSwitch?.isHidden = true
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        connectSwitch?.removeTarget(nil, action: nil, for: .valueChanged)
    }
}
