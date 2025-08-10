import CGMBLEKit
import CGMBLEKitUI
import LoopKitUI
import os.log

class CGMBLEKitG6Plugin: NSObject, CGMManagerUIPlugin {
    private let log = OSLog(category: "CGMBLEKitG6Plugin")

    public var cgmManagerType: CGMManagerUI.Type? {
        G6CGMManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
