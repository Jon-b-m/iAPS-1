import LoopKitUI
import os.log
import TidepoolServiceKit
import TidepoolServiceKitUI

class TidepoolServiceKitPlugin: NSObject, ServiceUIPlugin {
    private let log = OSLog(category: "TidepoolServiceKitPlugin")

    public var serviceType: ServiceUI.Type? {
        TidepoolService.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
