import RileyLinkBLEKit

extension RileyLinkDevice.IdleListeningState {
    static var enabledWithDefaults: RileyLinkDevice.IdleListeningState {
        .enabled(timeout: .minutes(1), channel: 0)
    }
}
