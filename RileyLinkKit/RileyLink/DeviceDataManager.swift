import Foundation
import LoopKit
import LoopKitUI
import MinimedKit
import MinimedKitUI
import NightscoutKit
import os.log
import RileyLinkBLEKit
import RileyLinkKit
import RileyLinkKitUI
import UserNotifications

class DeviceDataManager {
    let rileyLinkDeviceProvider: RileyLinkDeviceProvider

    var pumpManager: PumpManagerUI? {
        didSet {
            pumpManager?.pumpManagerDelegate = self
            UserDefaults.standard.pumpManagerRawValue = pumpManager?.rawValue
        }
    }

    public let log = OSLog(category: "DeviceDataManager")

    init() {
        let connectionManagerState = UserDefaults.standard.rileyLinkConnectionManagerState
        rileyLinkDeviceProvider = RileyLinkBluetoothDeviceProvider(autoConnectIDs: connectionManagerState?.autoConnectIDs ?? [])
        rileyLinkDeviceProvider.delegate = self
        rileyLinkDeviceProvider.setScanningEnabled(true)

        if let pumpManagerRawValue = UserDefaults.standard.pumpManagerRawValue {
            pumpManager = PumpManagerFromRawValue(
                pumpManagerRawValue,
                rileyLinkDeviceProvider: rileyLinkDeviceProvider
            ) as? PumpManagerUI
            pumpManager?.pumpManagerDelegate = self
        }
    }
}

extension DeviceDataManager: RileyLinkDeviceProviderDelegate {
    func rileylinkDeviceProvider(
        _: RileyLinkBLEKit.RileyLinkDeviceProvider,
        didChange state: RileyLinkBLEKit.RileyLinkConnectionState
    ) {
        UserDefaults.standard.rileyLinkConnectionManagerState = state
    }
}

extension DeviceDataManager: PumpManagerDelegate {
    func pumpManagerPumpWasReplaced(_: LoopKit.PumpManager) {}

    var detectedSystemTimeOffset: TimeInterval {
        0
    }

    func pumpManager(_: PumpManager, didAdjustPumpClockBy adjustment: TimeInterval) {
        log.debug("didAdjustPumpClockBy %@", adjustment)
    }

    func pumpManagerDidUpdateState(_ pumpManager: PumpManager) {
        UserDefaults.standard.pumpManagerRawValue = pumpManager.rawValue
    }

    func pumpManagerBLEHeartbeatDidFire(_: PumpManager) {}

    func pumpManagerMustProvideBLEHeartbeat(_: PumpManager) -> Bool {
        true
    }

    func pumpManager(_: PumpManager, didUpdate _: PumpManagerStatus, oldStatus _: PumpManagerStatus) {}

    func pumpManagerWillDeactivate(_: PumpManager) {
        pumpManager = nil
    }

    func pumpManager(_: PumpManager, didUpdatePumpRecordsBasalProfileStartEvents _: Bool) {}

    func pumpManager(_: PumpManager, didError error: PumpManagerError) {
        log.error("pumpManager didError %@", String(describing: error))
    }

    func pumpManager(
        _: PumpManager,
        hasNewPumpEvents _: [NewPumpEvent],
        lastSync _: Date?,
        completion _: @escaping (_ error: Error?) -> Void
    ) {}

    func pumpManager(
        _: PumpManager,
        didReadReservoirValue _: Double,
        at _: Date,
        completion _: @escaping (Result<
            (newValue: ReservoirValue, lastValue: ReservoirValue?, areStoredValuesContinuous: Bool),
            Error
        >) -> Void
    ) {}

    func pumpManagerRecommendsLoop(_: PumpManager) {}

    func startDateToFilterNewPumpEvents(for _: PumpManager) -> Date {
        Date().addingTimeInterval(.hours(-2))
    }
}

// MARK: - DeviceManagerDelegate

extension DeviceDataManager: DeviceManagerDelegate {
    func doesIssuedAlertExist(identifier _: LoopKit.Alert.Identifier, completion _: @escaping (Result<Bool, Error>) -> Void) {}

    func lookupAllUnretracted(
        managerIdentifier _: String,
        completion _: @escaping (Result<[LoopKit.PersistedAlert], Error>) -> Void
    ) {}

    func lookupAllUnacknowledgedUnretracted(
        managerIdentifier _: String,
        completion _: @escaping (Result<[LoopKit.PersistedAlert], Error>) -> Void
    ) {}

    func recordRetractedAlert(_: LoopKit.Alert, at _: Date) {}

    func deviceManager(
        _: DeviceManager,
        logEventForDeviceIdentifier _: String?,
        type _: DeviceLogEntryType,
        message _: String,
        completion _: ((Error?) -> Void)?
    ) {}
}

// MARK: - AlertPresenter

extension DeviceDataManager: AlertIssuer {
    func issueAlert(_: Alert) {}

    func retractAlert(identifier _: Alert.Identifier) {}
}
