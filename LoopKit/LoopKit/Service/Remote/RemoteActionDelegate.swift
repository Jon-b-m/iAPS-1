import Foundation

public protocol RemoteActionDelegate: AnyObject {
    func enactRemoteOverride(name: String, durationTime: TimeInterval?, remoteAddress: String) async throws
    func cancelRemoteOverride() async throws
    func deliverRemoteCarbs(
        amountInGrams: Double,
        absorptionTime: TimeInterval?,
        foodType: String?,
        startDate: Date?
    ) async throws
    func deliverRemoteBolus(amountInUnits: Double) async throws
}
