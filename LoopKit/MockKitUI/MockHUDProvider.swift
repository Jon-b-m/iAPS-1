import Foundation
import LoopKit
import LoopKitUI
import MockKit

final class MockHUDProvider: NSObject, HUDProvider {
    var managerIdentifier: String {
        MockPumpManager.pluginIdentifier
    }

    private var pumpManager: MockPumpManager

    private var lastPumpManagerStatus: PumpManagerStatus

    private weak var reservoirView: ReservoirVolumeHUDView?

    private weak var batteryView: BatteryLevelHUDView?

    init(pumpManager: MockPumpManager, allowedInsulinTypes _: [InsulinType]) {
        self.pumpManager = pumpManager
        lastPumpManagerStatus = pumpManager.status
        super.init()
        pumpManager.addStateObserver(self, queue: .main)
    }

    var visible: Bool = false

    var hudViewRawState: HUDViewRawState {
        var rawValue: HUDViewRawState = [
            "pumpReservoirCapacity": pumpManager.pumpReservoirCapacity
        ]

        if let pumpBatteryChargeRemaining = lastPumpManagerStatus.pumpBatteryChargeRemaining {
            rawValue["pumpBatteryChargeRemaining"] = pumpBatteryChargeRemaining
        }

        rawValue["reservoirUnitsRemaining"] = pumpManager.state.reservoirUnitsRemaining

        return rawValue
    }

    func createHUDView() -> BaseHUDView? {
        reservoirView = ReservoirVolumeHUDView.instantiate()
        updateReservoirView()

        return reservoirView
    }

    static func createHUDView(rawValue: HUDViewRawState) -> BaseHUDView? {
        guard let pumpReservoirCapacity = rawValue["pumpReservoirCapacity"] as? Double else {
            return nil
        }

        let reservoirVolumeHUDView = ReservoirVolumeHUDView.instantiate()
        if let reservoirUnitsRemaining = rawValue["reservoirUnitsRemaining"] as? Double {
            let reservoirLevel = (reservoirUnitsRemaining / pumpReservoirCapacity).clamped(to: 0 ... 1)
            reservoirVolumeHUDView.level = reservoirLevel
            reservoirVolumeHUDView.setReservoirVolume(volume: reservoirUnitsRemaining, at: Date())
        }

        return reservoirVolumeHUDView
    }

    func didTapOnHUDView(_: BaseHUDView, allowDebugFeatures _: Bool) -> HUDTapAction? {
        nil
    }

    private func updateReservoirView() {
        let reservoirVolume = pumpManager.state.reservoirUnitsRemaining
        let reservoirLevel = (reservoirVolume / pumpManager.pumpReservoirCapacity).clamped(to: 0 ... 1)
        reservoirView?.level = reservoirLevel
        reservoirView?.setReservoirVolume(volume: reservoirVolume, at: Date())
    }

    private func updateBatteryView() {
        batteryView?.batteryLevel = lastPumpManagerStatus.pumpBatteryChargeRemaining
    }
}

extension MockHUDProvider: MockPumpManagerStateObserver {
    func mockPumpManager(_: MockPumpManager, didUpdate _: MockPumpManagerState) {
        updateReservoirView()
    }

    func mockPumpManager(_: MockPumpManager, didUpdate status: PumpManagerStatus, oldStatus _: PumpManagerStatus) {
        lastPumpManagerStatus = status
        updateBatteryView()
    }
}
