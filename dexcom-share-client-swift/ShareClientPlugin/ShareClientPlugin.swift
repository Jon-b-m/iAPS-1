import LoopKitUI
import os.log
import ShareClient
import ShareClientUI

class ShareClientPlugin: NSObject, CGMManagerUIPlugin {
    private let log = OSLog(category: "ShareClientPlugin")

    public var cgmManagerType: CGMManagerUI.Type? {
        ShareClientManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
