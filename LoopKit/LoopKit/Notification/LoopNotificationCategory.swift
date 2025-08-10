import Foundation

public enum LoopNotificationCategory: String {
    case bolusFailure
    case loopNotRunning
    case pumpBatteryLow
    case pumpReservoirEmpty
    case pumpReservoirLow
    case pumpExpirationWarning
    case pumpExpired
    case pumpFault
    case alert
    case remoteBolus
    case remoteBolusFailure
    case remoteCarbs
    case remoteCarbsFailure
    case missedMeal
}
