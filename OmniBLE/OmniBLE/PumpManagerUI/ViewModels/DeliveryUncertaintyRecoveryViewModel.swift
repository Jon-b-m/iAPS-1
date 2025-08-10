import Foundation
import LoopKit

class DeliveryUncertaintyRecoveryViewModel: PumpManagerStatusObserver {
    let appName: String
    let uncertaintyStartedAt: Date

    var onDismiss: (() -> Void)?
    var didRecover: (() -> Void)?
    var onDeactivate: (() -> Void)?

    private var finished = false

    init(appName: String, uncertaintyStartedAt: Date) {
        self.appName = appName
        self.uncertaintyStartedAt = uncertaintyStartedAt
    }

    func pumpManager(_: PumpManager, didUpdate status: PumpManagerStatus, oldStatus _: PumpManagerStatus) {
        if !finished {
            if !status.deliveryIsUncertain {
                didRecover?()
            }
        }
    }

    func podDeactivationChosen() {
        finished = true
        onDeactivate?()
    }
}
