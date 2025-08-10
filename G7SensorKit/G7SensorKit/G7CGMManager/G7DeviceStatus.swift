import LoopKit
import LoopKitUI

public struct G7DeviceStatusHighlight: DeviceStatusHighlight, Equatable {
    public let localizedMessage: String
    public let imageName: String
    public let state: DeviceStatusHighlightState
    init(localizedMessage: String, imageName: String, state: DeviceStatusHighlightState) {
        self.localizedMessage = localizedMessage
        self.imageName = imageName
        self.state = state
    }
}
