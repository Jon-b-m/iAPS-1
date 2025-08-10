import Foundation

extension DateComponents {
    init(gregorianYear year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        self.init()

        calendar = Calendar(identifier: Calendar.Identifier.gregorian)

        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
    }
}
