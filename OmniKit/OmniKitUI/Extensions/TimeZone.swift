import Foundation

extension TimeZone {
    static var currentFixed: TimeZone {
        TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!
    }

    var fixed: TimeZone {
        TimeZone(secondsFromGMT: secondsFromGMT())!
    }

    /// This only works for fixed utc offset timezones
    func scheduleOffset(forDate date: Date) -> TimeInterval {
        var calendar = Calendar.current
        calendar.timeZone = self
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        guard let startOfSchedule = calendar.date(from: components) else {
            fatalError("invalid date")
        }
        return date.timeIntervalSince(startOfSchedule)
    }
}
