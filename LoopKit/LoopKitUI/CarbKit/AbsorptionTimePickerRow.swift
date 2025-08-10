import SwiftUI

public struct AbsorptionTimePickerRow: View {
    @Binding private var absorptionTime: TimeInterval
    @Binding private var isFocused: Bool

    private let validDurationRange: ClosedRange<TimeInterval>
    private let minuteStride: Int

    private var showHowAbsorptionTimeWorks: Binding<Bool>?

    private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()

    public init(
        absorptionTime: Binding<TimeInterval>,
        isFocused: Binding<Bool>,
        validDurationRange: ClosedRange<TimeInterval>,
        minuteStride: Int = 30,
        showHowAbsorptionTimeWorks: Binding<Bool>? = nil
    ) {
        _absorptionTime = absorptionTime
        _isFocused = isFocused
        self.validDurationRange = validDurationRange
        self.minuteStride = minuteStride
        self.showHowAbsorptionTimeWorks = showHowAbsorptionTimeWorks
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Absorption Time")
                    .foregroundColor(.primary)

                if showHowAbsorptionTimeWorks != nil {
                    Button(action: {
                        isFocused = false
                        showHowAbsorptionTimeWorks?.wrappedValue = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                }

                Spacer()

                Text(durationString())
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            if isFocused {
                DurationPicker(duration: $absorptionTime, validDurationRange: validDurationRange, minuteInterval: minuteStride)
                    .frame(maxWidth: .infinity)
            }
        }
        .onTapGesture {
            withAnimation {
                isFocused.toggle()
            }
        }
    }

    private func durationString() -> String {
        durationFormatter.string(from: absorptionTime) ?? ""
    }
}
