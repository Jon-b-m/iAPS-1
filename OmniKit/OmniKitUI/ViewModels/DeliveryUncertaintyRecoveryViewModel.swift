import Foundation
import LoopKit

class DeliveryUncertaintyRecoveryViewModel: PumpManagerStatusObserver {
    let appName: String
    let uncertaintyStartedAt: Date
    var respondToRecovery: Bool

    var onDismiss: (() -> Void)?
    var didRecover: (() -> Void)?
    var onDeactivate: (() -> Void)?

    init(appName: String, uncertaintyStartedAt: Date) {
        self.appName = appName
        self.uncertaintyStartedAt = uncertaintyStartedAt
        respondToRecovery = false
    }

    func pumpManager(_: PumpManager, didUpdate status: PumpManagerStatus, oldStatus _: PumpManagerStatus) {
        if !status.deliveryIsUncertain, respondToRecovery {
            didRecover?()
        }
    }

    func podDeactivationChosen() {
        onDeactivate?()
    }
}
