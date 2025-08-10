import Foundation
import RileyLinkBLEKit

class MockRileyLinkProvider: RileyLinkDeviceProvider {
    init(devices: [RileyLinkDevice]) {
        self.devices = devices
    }

    var devices: [RileyLinkDevice]

    var delegate: RileyLinkDeviceProviderDelegate?

    var idleListeningState: RileyLinkBluetoothDevice.IdleListeningState = .disabled

    var idleListeningEnabled: Bool = false

    var timerTickEnabled: Bool = false

    var connectingCount: Int = 0

    func deprioritize(_: RileyLinkDevice, completion _: (() -> Void)?) {}

    func assertIdleListening(forcingRestart _: Bool) {}

    func getDevices(_ completion: @escaping ([RileyLinkDevice]) -> Void) {
        completion(devices)
    }

    func connect(_: RileyLinkDevice) {}

    func disconnect(_: RileyLinkDevice) {}

    func setScanningEnabled(_: Bool) {}

    func shouldConnect(to _: String) -> Bool {
        false
    }

    var debugDescription: String = "MockRileyLinkProvider"
}
