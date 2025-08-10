import Foundation

extension UserDefaults {
    var passiveModeEnabled: Bool {
        get {
            bool(forKey: "passiveModeEnabled")
        }
        set {
            set(newValue, forKey: "passiveModeEnabled")
        }
    }

    var stayConnected: Bool {
        get {
            object(forKey: "stayConnected") != nil ? bool(forKey: "stayConnected") : true
        }
        set {
            set(newValue, forKey: "stayConnected")
        }
    }

    var transmitterID: String {
        get {
            string(forKey: "transmitterID") ?? "500000"
        }
        set {
            set(newValue, forKey: "transmitterID")
        }
    }
}
