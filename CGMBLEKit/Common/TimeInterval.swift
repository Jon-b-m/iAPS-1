import Foundation

extension TimeInterval {
    static func hours(_ hours: Double) -> TimeInterval {
        self.init(hours: hours)
    }

    static func minutes(_ minutes: Int) -> TimeInterval {
        self.init(minutes: Double(minutes))
    }

    static func minutes(_ minutes: Double) -> TimeInterval {
        self.init(minutes: minutes)
    }

    static func seconds(_ seconds: Double) -> TimeInterval {
        self.init(seconds)
    }

    static func milliseconds(_ milliseconds: Double) -> TimeInterval {
        self.init(milliseconds / 1000)
    }

    init(minutes: Double) {
        self.init(minutes * 60)
    }

    init(hours: Double) {
        self.init(minutes: hours * 60)
    }

    init(seconds: Double) {
        self.init(seconds)
    }

    init(milliseconds: Double) {
        self.init(milliseconds / 1000)
    }

    var milliseconds: Double {
        self * 1000
    }

    var minutes: Double {
        self / 60.0
    }

    var hours: Double {
        minutes / 60.0
    }
}
