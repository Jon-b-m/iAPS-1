import RileyLinkBLEKit

public extension RileyLinkDeviceProvider {
    func firstConnectedDevice(_ completion: @escaping (_ device: RileyLinkDevice?) -> Void) {
        getDevices { devices in
            completion(devices.firstConnected)
        }
    }
}
