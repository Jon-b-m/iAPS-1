import Foundation
import MinimedKit
import RileyLinkBLEKit

class MockPumpOps: PumpOps, PumpOpsSessionDelegate {
    let queue = DispatchQueue(label: "MockPumpOps")

    var pumpState: PumpState

    var pumpSettings: PumpSettings

    var messageSender: MockPumpMessageSender

    func pumpOpsSession(_: MinimedKit.PumpOpsSession, didChange state: MinimedKit.PumpState) {
        pumpState = state
    }

    func pumpOpsSessionDidChangeRadioConfig(_: MinimedKit.PumpOpsSession) {}

    public func runSession(withName _: String, using _: RileyLinkDevice, _ block: @escaping (_ session: PumpOpsSession) -> Void) {
        let session = PumpOpsSession(settings: pumpSettings, pumpState: pumpState, messageSender: messageSender, delegate: self)
        queue.async {
            block(session)
        }
    }

    init(pumpState: PumpState, pumpSettings: PumpSettings, messageSender: MockPumpMessageSender = MockPumpMessageSender()) {
        self.pumpState = pumpState
        self.pumpSettings = pumpSettings
        self.messageSender = messageSender
    }
}
