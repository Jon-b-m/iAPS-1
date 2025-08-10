import Foundation
import LoopKitUI
import OmniBLE
import os.log

class OmniBLEPlugin: NSObject, PumpManagerUIPlugin {
    private let log = OSLog(category: "OmniBLEPlugin")

    public var pumpManagerType: PumpManagerUI.Type? {
        OmniBLEPumpManager.self
    }

    public var cgmManagerType: CGMManagerUI.Type? {
        nil
    }

    override init() {
        super.init()
        log.default("OmniBLEPlugin Instantiated")
    }
}
