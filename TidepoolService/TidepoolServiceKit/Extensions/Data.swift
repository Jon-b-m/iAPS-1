import CryptoKit

extension Data {
    var md5hash: String? {
        let hash = Insecure.MD5.hash(data: self)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
