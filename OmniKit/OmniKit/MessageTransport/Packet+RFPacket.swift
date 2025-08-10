import Foundation
import RileyLinkBLEKit

// Extensions for RFPacket support
extension Packet {
    init(rfPacket: RFPacket) throws {
        try self.init(encodedData: rfPacket.data)
    }
}
