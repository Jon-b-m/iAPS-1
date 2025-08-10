import Foundation
import HealthKit

public struct Calibration {
    init?(calibrationMessage: CalibrationDataRxMessage, activationDate: Date) {
        guard calibrationMessage.glucose > 0 else {
            return nil
        }

        let unit = HKUnit.milligramsPerDeciliter

        glucose = HKQuantity(unit: unit, doubleValue: Double(calibrationMessage.glucose))
        date = activationDate.addingTimeInterval(TimeInterval(calibrationMessage.timestamp))
    }

    public let glucose: HKQuantity
    public let date: Date
}
