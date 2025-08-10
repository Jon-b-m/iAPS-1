import CoreBluetooth
import Foundation
import RileyLinkBLEKit

class MockRileyLinkDevice: RileyLinkDevice {
    var isConnected: Bool = true

    var rlFirmwareDescription: String = "Mock"

    var hasOrangeLinkService: Bool = false

    var hardwareType: RileyLinkHardwareType? = .riley

    var rssi: Int?

    var name: String? = "Mock"

    var deviceURI: String = "rileylink://Mock"

    var peripheralIdentifier = UUID()

    var peripheralState: CBPeripheralState = .connected

    func readRSSI() {}

    func setCustomName(_: String) {}

    func updateBatteryLevel() {}

    func orangeAction(_: OrangeLinkCommand) {}

    func setOrangeConfig(_: OrangeLinkConfigurationSetting, isOn _: Bool) {}

    func orangeWritePwd() {}

    func orangeClose() {}

    func orangeReadSet() {}

    func orangeReadVDC() {}

    func findDevice() {}

    func setDiagnosticeLEDModeForBLEChip(_: RileyLinkLEDMode) {}

    func readDiagnosticLEDModeForBLEChip(completion _: @escaping (RileyLinkLEDMode?) -> Void) {}

    func assertOnSessionQueue() {}

    func sessionQueueAsyncAfter(deadline _: DispatchTime, execute _: @escaping () -> Void) {}

    func runSession(withName _: String, _: @escaping (CommandSession) -> Void) {
        assertionFailure(
            "MockRileyLinkDevice.runSession should not be called during testing.  Use MockPumpOps for communication stubs."
        )
    }

    func getStatus(_ completion: @escaping (RileyLinkDeviceStatus) -> Void) {
        completion(RileyLinkDeviceStatus(
            lastIdle: Date(),
            name: name,
            version: rlFirmwareDescription,
            ledOn: false,
            vibrationOn: false,
            voltage: 3.0,
            battery: nil,
            hasPiezo: false
        ))
    }
}
