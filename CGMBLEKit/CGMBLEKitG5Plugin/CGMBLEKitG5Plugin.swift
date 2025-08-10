import CGMBLEKit
import CGMBLEKitUI
import LoopKitUI
import os.log

class CGMBLEKitG5Plugin: NSObject, CGMManagerUIPlugin {
    private let log = OSLog(category: "CGMBLEKitG5Plugin")

    public var cgmManagerType: CGMManagerUI.Type? {
        G5CGMManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
