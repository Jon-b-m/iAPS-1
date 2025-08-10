import Foundation

extension DateFormatter {
    convenience init(dateStyle: Style = .none, timeStyle: Style = .none) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
}
