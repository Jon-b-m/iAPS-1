import CryptoKit

extension String {
    var md5hash: String? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
