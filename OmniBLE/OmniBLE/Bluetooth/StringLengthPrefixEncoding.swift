import Foundation

final class StringLengthPrefixEncoding {
    private static let LENGTH_BYTES = 2

    static func parseKeys(_ keys: [String], _ payload: Data) throws -> [Data] {
        var ret = [Data](repeating: Data(capacity: 0), count: keys.count)
        var remaining = payload
        for (index, key) in keys.enumerated() {
            guard remaining.count >= key.count else {
                throw PodProtocolError.messageIOException("Payload too short: \(payload)")
            }
            if String(decoding: remaining.subdata(in: 0 ..< key.count), as: UTF8.self) != key {
                throw PodProtocolError.messageIOException("Key not found: \(key) in \(payload.hexadecimalString)")
            }
            // last key can be empty, no length
            else if index == keys.count - 1, remaining.count == key.count {
                return ret
            }
            guard remaining.count >= (key.count + LENGTH_BYTES) else {
                throw PodProtocolError.messageIOException("Payload too short: \(payload)")
            }
            remaining = remaining.subdata(in: key.count ..< remaining.count)
            let length = Int(remaining[0...].toBigEndian(UInt16.self))
            guard remaining.count >= length else {
                throw PodProtocolError.messageIOException("Payload too short: \(payload)")
            }
            ret[index] = remaining.subdata(in: LENGTH_BYTES ..< LENGTH_BYTES + length)
            remaining = remaining.subdata(in: LENGTH_BYTES + length ..< remaining.count)
        }
        return ret
    }

    static func formatKeys(keys: [String], payloads: [Data]) -> Data {
        let payloadTotalSize = payloads.reduce(0, { acc, i in acc + i.count })
        let keyTotalSize = keys.reduce(0, { acc, i in acc + i.count })
        let zeros = payloads.reduce(0, { acc, i in acc + (i.isEmpty ? 1 : 0) })

        var bb = Data(capacity: 2 * (keys.count - zeros) + keyTotalSize + payloadTotalSize)
        for (idx, key) in keys.enumerated() {
            let payload = payloads[idx]
            bb.append(key.data(using: .utf8)!)
            if !payload.isEmpty {
                bb.append(withUnsafeBytes(of: Int16(payload.count).bigEndian) { Data($0) })
                bb.append(payload)
            }
        }

        return bb
    }
}
