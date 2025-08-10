import Foundation
import LoopKit
import MinimedKit
import OmniKit
import RileyLinkBLEKit

let allPumpManagers: [String: PumpManager.Type] = [
    MinimedPumpManager.managerIdentifier: MinimedPumpManager.self
]

func PumpManagerFromRawValue(_ rawValue: [String: Any], rileyLinkDeviceProvider: RileyLinkDeviceProvider) -> PumpManager? {
    guard let managerIdentifier = rawValue["managerIdentifier"] as? String,
          let rawState = rawValue["state"] as? PumpManager.RawStateValue
    else {
        return nil
    }

    switch managerIdentifier {
    case MinimedPumpManager.managerIdentifier:
        guard let state = MinimedPumpManagerState(rawValue: rawState) else {
            return nil
        }
        return MinimedPumpManager(state: state, rileyLinkDeviceProvider: rileyLinkDeviceProvider)
    case OmnipodPumpManager.managerIdentifier:
        guard let state = OmnipodPumpManagerState(rawValue: rawState) else {
            return nil
        }
        return OmnipodPumpManager(state: state, rileyLinkDeviceProvider: rileyLinkDeviceProvider)
    default:
        return nil
    }
}

extension PumpManager {
    var rawValue: [String: Any] {
        [
            "managerIdentifier": type(of: self).managerIdentifier,
            "state": rawState
        ]
    }
}
