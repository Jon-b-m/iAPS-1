import LoopKit
import UIKit

public protocol DeviceStatusBadge {
    /// the image to present as the badge
    var image: UIImage? { get }

    /// the state of the status badge (guides presentation)
    var state: DeviceStatusBadgeState { get }
}

public typealias DeviceStatusBadgeState = DeviceStatusElementState
