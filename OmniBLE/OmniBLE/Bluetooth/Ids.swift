import Foundation

let CONTROLLER_ID: UInt32 = 0x1092 // fixed AAPS controller Id #
let POD_ID_NOT_ACTIVATED = Data(hexadecimalString: "FFFFFFFE")!

public class Ids {
    static func notActivated() -> Id {
        Id(POD_ID_NOT_ACTIVATED)
    }

    private let controllerId: Id
    private let currentPodId: Id

    var myId: Id {
        controllerId
    }

    var podId: Id {
        currentPodId
    }

    var myIdAddr: UInt32 {
        controllerId.toUInt32()
    }

    var podIdAddr: UInt32 {
        currentPodId.toUInt32()
    }

    init(myId: UInt32, podId: UInt32) {
        controllerId = Id.fromUInt32(myId)
        currentPodId = Id.fromUInt32(podId)
    }
}
