import LoopKitUI
import MinimedKit
import MinimedKitUI
import os.log

class MinimedKitPlugin: NSObject, PumpManagerUIPlugin {
    private let log = OSLog(category: "MinimedKitPlugin")

    public var pumpManagerType: PumpManagerUI.Type? {
        MinimedPumpManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
