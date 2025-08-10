import Foundation

// MARK: - Extensions useful in parsing fixture dates

extension ISO8601DateFormatter {
    static func localTimeDate(timeZone: TimeZone = .currentFixed) -> Self {
        let formatter = self.init()

        formatter.formatOptions = .withInternetDateTime
        formatter.formatOptions.subtract(.withTimeZone)
        formatter.timeZone = timeZone

        return formatter
    }
}

extension DateFormatter {
    static var descriptionFormatter: DateFormatter {
        let formatter = self.init()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"

        return formatter
    }
}
