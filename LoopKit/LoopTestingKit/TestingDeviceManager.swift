import HealthKit
import LoopKit

public protocol TestingDeviceManager: DeviceManager {
    var testingDevice: HKDevice { get }

    func acceptDefaultsAndSkipOnboarding()
    func trigger(action: DeviceAction)
}
