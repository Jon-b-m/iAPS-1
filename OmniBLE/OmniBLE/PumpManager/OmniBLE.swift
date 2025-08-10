import Foundation
import OSLog

public class OmniBLE {
    var manager: PeripheralManager
    var advertisement: PodAdvertisement?

    private let log = OSLog(category: "OmniBLE")

    init(peripheralManager: PeripheralManager, advertisement: PodAdvertisement?) {
        manager = peripheralManager
        self.advertisement = advertisement
    }
}

extension OmniBLE: CustomDebugStringConvertible {
    public var debugDescription: String {
        "OmniBLE - advertisement: \(String(describing: advertisement))"
    }
}
