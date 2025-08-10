import Foundation

public class SetRemoteControlEnabledMessageBody: CarelinkLongMessageBody {
    public convenience init(enabled: Bool) {
        self.init(rxData: Data([1, enabled ? 1 : 0]))!
    }
}
