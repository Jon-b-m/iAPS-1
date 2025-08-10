import SwiftUI

public struct LabeledDateView: View {
    var label: String
    var date: Date?
    var dateFormatter: DateFormatter

    private var dateString: String? {
        guard let date = self.date else {
            return nil
        }
        return dateFormatter.string(from: date)
    }

    public init(label: String, date: Date?, dateFormatter: DateFormatter) {
        self.label = label
        self.date = date
        self.dateFormatter = dateFormatter
    }

    public var body: some View {
        LabeledValueView(
            label: label,
            value: dateString
        )
    }
}

struct LabeledDateView_Previews: PreviewProvider {
    static var previews: some View {
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }
        return LabeledDateView(
            label: "Last Calibration",
            date: Date(),
            dateFormatter: dateFormatter
        )
    }
}
