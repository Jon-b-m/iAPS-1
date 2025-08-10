import Foundation

extension Date {
    var timeString: String {
        Date.timeFormatter.string(from: roundedToTimeInterval(.millisecond))
    }

    private static let timeFormatter: ISO8601DateFormatter = {
        var timeFormatter = ISO8601DateFormatter()
        timeFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return timeFormatter
    }()

    private func roundedToTimeInterval(_ interval: TimeInterval) -> Date {
        guard interval != 0 else {
            return self
        }
        return Date(timeIntervalSinceReferenceDate: round(timeIntervalSinceReferenceDate / interval) * interval)
    }
}
