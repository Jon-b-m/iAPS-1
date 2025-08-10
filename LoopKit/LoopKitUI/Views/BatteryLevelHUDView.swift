import UIKit

public final class BatteryLevelHUDView: LevelHUDView, NibLoadable {
    override public var orderPriority: HUDViewOrderPriority {
        5
    }

    public class func instantiate() -> BatteryLevelHUDView {
        nib().instantiate(withOwner: nil, options: nil)[0] as! BatteryLevelHUDView
    }

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent

        return formatter
    }()

    public var batteryLevel: Double? {
        didSet {
            if let value = batteryLevel, let level = numberFormatter.string(from: value) {
                caption.text = level
                accessibilityValue = level
            } else {
                caption.text = nil
                accessibilityValue = nil
            }

            level = batteryLevel
        }
    }
}
