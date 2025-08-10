import MinimedKit
import NightscoutKit

public extension BatteryIndicator {
    init?(batteryStatus: MinimedKit.BatteryStatus) {
        switch batteryStatus {
        case .low:
            self = .low
        case .normal:
            self = .normal
        default:
            return nil
        }
    }
}
