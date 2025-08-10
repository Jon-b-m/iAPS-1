import G7SensorKit
import G7SensorKitUI
import LoopKitUI
import os.log

class G7SensorPlugin: NSObject, CGMManagerUIPlugin {
    private let log = OSLog(category: "G7Plugin")

    public var cgmManagerType: CGMManagerUI.Type? {
        G7CGMManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
