import HealthKit

struct CodableDevice: Codable {
    let name: String?
    let manufacturer: String?
    let model: String?
    let hardwareVersion: String?
    let firmwareVersion: String?
    let softwareVersion: String?
    let localIdentifier: String?
    let udiDeviceIdentifier: String?

    init(_ device: HKDevice) {
        name = device.name
        manufacturer = device.manufacturer
        model = device.model
        hardwareVersion = device.hardwareVersion
        firmwareVersion = device.firmwareVersion
        softwareVersion = device.softwareVersion
        localIdentifier = device.localIdentifier
        udiDeviceIdentifier = device.udiDeviceIdentifier
    }

    var device: HKDevice {
        HKDevice(
            name: name,
            manufacturer: manufacturer,
            model: model,
            hardwareVersion: hardwareVersion,
            firmwareVersion: firmwareVersion,
            softwareVersion: softwareVersion,
            localIdentifier: localIdentifier,
            udiDeviceIdentifier: udiDeviceIdentifier
        )
    }
}
