import Foundation

public struct CalibrateGlucoseRxMessage: TransmitterRxMessage {
    init?(data: Data) {
        guard data.count == 5, data.isCRCValid else {
            return nil
        }

        guard data.starts(with: .calibrateGlucoseRx) else {
            return nil
        }
    }
}
