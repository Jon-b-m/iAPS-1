import Foundation
import LoopKit

class MockPumpManagerDelegate: PumpManagerDelegate {
    var automaticDosingEnabled = true

    var historyFetchStartDate = Date()

    func pumpManagerBLEHeartbeatDidFire(_: PumpManager) {}

    func pumpManagerMustProvideBLEHeartbeat(_: PumpManager) -> Bool {
        false
    }

    func pumpManagerWillDeactivate(_: PumpManager) {}

    func pumpManagerPumpWasReplaced(_: PumpManager) {}

    func pumpManager(_: PumpManager, didUpdatePumpRecordsBasalProfileStartEvents _: Bool) {}

    func pumpManager(_: PumpManager, didError _: PumpManagerError) {}

    var reportedPumpEvents: [(events: [NewPumpEvent], lastReconciliation: Date?)] = []

    func pumpManager(
        _: PumpManager,
        hasNewPumpEvents events: [NewPumpEvent],
        lastReconciliation: Date?,
        replacePendingEvents _: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        reportedPumpEvents.append((events: events, lastReconciliation: lastReconciliation))
        completion(nil)
    }

    struct MockReservoirValue: ReservoirValue {
        let startDate: Date
        let unitVolume: Double
    }

    func pumpManager(
        _: PumpManager,
        didReadReservoirValue units: Double,
        at date: Date,
        completion: @escaping (Result<
            (newValue: ReservoirValue, lastValue: ReservoirValue?, areStoredValuesContinuous: Bool),
            Error
        >) -> Void
    )
    {
        let reservoirValue = MockReservoirValue(startDate: date, unitVolume: units)
        DispatchQueue.main.async {
            completion(.success((newValue: reservoirValue, lastValue: nil, areStoredValuesContinuous: true)))
        }
    }

    func pumpManager(_: PumpManager, didAdjustPumpClockBy _: TimeInterval) {}

    func pumpManagerDidUpdateState(_: PumpManager) {}

    func pumpManager(
        _: PumpManager,
        didRequestBasalRateScheduleChange _: BasalRateSchedule,
        completion _: @escaping (Error?) -> Void
    ) {}

    func startDateToFilterNewPumpEvents(for _: PumpManager) -> Date {
        historyFetchStartDate
    }

    var detectedSystemTimeOffset: TimeInterval = 0

    func deviceManager(
        _: DeviceManager,
        logEventForDeviceIdentifier _: String?,
        type _: DeviceLogEntryType,
        message _: String,
        completion _: ((Error?) -> Void)?
    ) {}

    func pumpManager(_: PumpManager, didUpdate _: PumpManagerStatus, oldStatus _: PumpManagerStatus) {}

    func issueAlert(_: Alert) {}

    func retractAlert(identifier _: Alert.Identifier) {}

    func doesIssuedAlertExist(identifier _: Alert.Identifier, completion _: @escaping (Result<Bool, Error>) -> Void) {}

    func lookupAllUnretracted(managerIdentifier _: String, completion _: @escaping (Result<[PersistedAlert], Error>) -> Void) {}

    func lookupAllUnacknowledgedUnretracted(
        managerIdentifier _: String,
        completion _: @escaping (Result<[PersistedAlert], Error>) -> Void
    ) {}

    func recordRetractedAlert(_: Alert, at _: Date) {}
}
