import Foundation

class LocalBundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var main: Bundle = {
        if let mainResourceURL = Bundle(for: LocalBundle.self).resourceURL,
           let bundle = Bundle(url: mainResourceURL.appendingPathComponent("LoopKit_LoopKit.bundle"))
        {
            return bundle
        }
        return Bundle(for: LocalBundle.self)
    }()
}

func LocalizedString(_ key: String, tableName: String? = nil, value: String? = nil, comment: String) -> String {
    if let value = value {
        return NSLocalizedString(key, tableName: tableName, bundle: LocalBundle.main, value: value, comment: comment)
    } else {
        return NSLocalizedString(key, tableName: tableName, bundle: LocalBundle.main, comment: comment)
    }
}
