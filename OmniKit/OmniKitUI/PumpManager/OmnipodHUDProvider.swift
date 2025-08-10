import LoopKit
import LoopKitUI
import OmniKit
import SwiftUI
import UIKit

public enum ReservoirAlertState {
    case ok
    case lowReservoir
    case empty
}

internal class OmnipodHUDProvider: NSObject, HUDProvider {
    var managerIdentifier: String {
        pumpManager.pluginIdentifier
    }

    private let pumpManager: OmnipodPumpManager

    private var reservoirView: OmnipodReservoirView?

    private let bluetoothProvider: BluetoothProvider

    private let colorPalette: LoopUIColorPalette

    private var refreshTimer: Timer?

    private let allowedInsulinTypes: [InsulinType]

    var visible: Bool = false {
        didSet {
            if oldValue != visible, visible {
                hudDidAppear()
            }
        }
    }

    public init(
        pumpManager: OmnipodPumpManager,
        bluetoothProvider: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowedInsulinTypes: [InsulinType]
    ) {
        self.pumpManager = pumpManager
        self.bluetoothProvider = bluetoothProvider
        self.colorPalette = colorPalette
        self.allowedInsulinTypes = allowedInsulinTypes
        super.init()
        self.pumpManager.addPodStateObserver(self, queue: .main)
    }

    public func createHUDView() -> BaseHUDView? {
        reservoirView = OmnipodReservoirView.instantiate()
        updateReservoirView()

        return reservoirView
    }

    public func didTapOnHUDView(_: BaseHUDView, allowDebugFeatures: Bool) -> HUDTapAction? {
        let vc = pumpManager.settingsViewController(
            bluetoothProvider: bluetoothProvider,
            colorPalette: colorPalette,
            allowDebugFeatures: allowDebugFeatures,
            allowedInsulinTypes: allowedInsulinTypes
        )
        return HUDTapAction.presentViewController(vc)
    }

    func hudDidAppear() {
        updateReservoirView()
        refresh()
    }

    public var hudViewRawState: HUDProvider.HUDViewRawState {
        var rawValue: HUDProvider.HUDViewRawState = [:]

        rawValue["lastStatusDate"] = pumpManager.lastStatusDate

        if let reservoirLevel = pumpManager.reservoirLevel {
            rawValue["reservoirLevel"] = reservoirLevel.rawValue
        }

        if let reservoirLevelHighlightState = pumpManager.reservoirLevelHighlightState {
            rawValue["reservoirLevelHighlightState"] = reservoirLevelHighlightState.rawValue
        }

        return rawValue
    }

    public static func createHUDView(rawValue: HUDProvider.HUDViewRawState) -> BaseHUDView? {
        guard let rawReservoirLevel = rawValue["reservoirLevel"] as? ReservoirLevel.RawValue,
              let rawReservoirLevelHighlightState = rawValue["reservoirLevelHighlightState"] as? ReservoirLevelHighlightState
              .RawValue,
              let reservoirLevelHighlightState = ReservoirLevelHighlightState(rawValue: rawReservoirLevelHighlightState)
        else {
            return nil
        }

        let reservoirView: OmnipodReservoirView?

        let reservoirLevel = ReservoirLevel(rawValue: rawReservoirLevel)

        if let lastStatusDate = rawValue["lastStatusDate"] as? Date {
            reservoirView = OmnipodReservoirView.instantiate()
            reservoirView!.update(
                level: reservoirLevel,
                at: lastStatusDate,
                reservoirLevelHighlightState: reservoirLevelHighlightState
            )
        } else {
            reservoirView = nil
        }

        return reservoirView
    }

    private func refresh() {
        pumpManager.getPodStatus { _ in
            DispatchQueue.main.async {
                self.updateReservoirView()
            }
        }
    }

    private func updateReservoirView() {
        guard let reservoirView = reservoirView,
              let lastStatusDate = pumpManager.lastStatusDate,
              let reservoirLevelHighlightState = pumpManager.reservoirLevelHighlightState
        else {
            return
        }

        reservoirView.update(
            level: pumpManager.reservoirLevel,
            at: lastStatusDate,
            reservoirLevelHighlightState: reservoirLevelHighlightState
        )
    }
}

extension OmnipodHUDProvider: PodStateObserver {
    func podConnectionStateDidChange(isConnected _: Bool) {
        // ignore for now
    }

    func podStateDidUpdate(_: PodState?) {
        updateReservoirView()
    }
}
