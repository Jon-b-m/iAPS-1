import HealthKit
import RileyLinkBLEKit

extension RileyLinkDeviceStatus {
    func device(pumpID: String, pumpModel: PumpModel) -> HKDevice {
        HKDevice(
            name: name,
            manufacturer: "Medtronic",
            model: pumpModel.rawValue,
            hardwareVersion: nil,
            firmwareVersion: version,
            softwareVersion: String(MinimedKitVersionNumber),
            localIdentifier: pumpID,
            udiDeviceIdentifier: nil
        )
    }
}
