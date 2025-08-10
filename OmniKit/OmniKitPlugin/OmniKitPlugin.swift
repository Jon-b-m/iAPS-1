import LoopKitUI
import OmniKit
import OmniKitUI
import os.log

class OmniKitPlugin: NSObject, PumpManagerUIPlugin {
    private let log = OSLog(category: "OmniKitPlugin")

    public var pumpManagerType: PumpManagerUI.Type? {
        OmnipodPumpManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
