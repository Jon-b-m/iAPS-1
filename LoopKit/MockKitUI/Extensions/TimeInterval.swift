import Foundation

extension TimeInterval {
    static func minutes(_ minutes: Double) -> TimeInterval {
        self.init(minutes: minutes)
    }

    static func hours(_ hours: Double) -> TimeInterval {
        self.init(hours: hours)
    }

    init(minutes: Double) {
        self.init(minutes * 60)
    }

    init(hours: Double) {
        self.init(minutes: hours * 60)
    }

    init(days: Double) {
        self.init(hours: days * 24)
    }

    var minutes: Double {
        self / 60.0
    }

    var hours: Double {
        minutes / 60.0
    }

    var days: Double {
        hours / 24.0
    }
}
