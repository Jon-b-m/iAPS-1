import SwiftUI

public struct OverrideViewCell: View {
    @Environment(\.lightenedInsulinTintColor) private var lightInsulin
    @Environment(\.darkenedInsulinTintColor) private var darkInsulin

    static let symbolWidth: CGFloat = 40

    var symbolLabel: Text
    var nameLabel: Text
    var targetRangeLabel: Text
    var durationLabel: Text
    var subtitleLabel: Text
    var insulinNeedsScaleFactor: Double?

    public init(
        symbol: Text,
        name: Text,
        targetRange: Text,
        duration: Text,
        subtitle: Text,
        insulinNeedsScaleFactor: Double?
    ) {
        symbolLabel = symbol
        nameLabel = name
        targetRangeLabel = targetRange
        durationLabel = duration
        subtitleLabel = subtitle
        self.insulinNeedsScaleFactor = insulinNeedsScaleFactor
    }

    public var body: some View {
        HStack {
            symbolLabel
                .font(.largeTitle)
                .frame(width: Self.symbolWidth) // for alignment
            VStack(alignment: .leading, spacing: 3) {
                nameLabel
                targetRangeLabel
                    .font(.caption)
                    .foregroundColor(Color.gray)
                if self.insulinNeedsScaleFactor != nil {
                    insulinNeedsBar
                }
            }
            Spacer()
            VStack {
                HStack(spacing: 4) {
                    timer
                    durationLabel
                        .font(.caption)
                }
                .foregroundColor(Color.gray)
                subtitleLabel
                    .font(.caption)
            }
        }
        .frame(minHeight: 53)
    }

    private var insulinNeedsBar: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    if self.insulinNeedsScaleFactor != nil {
                        SegmentedGaugeBar(
                            insulinNeedsScaler: self.insulinNeedsScaleFactor!,
                            startColor: lightInsulin,
                            endColor: darkInsulin
                        )
                        .frame(minHeight: 12)
                    }
                }
                Spacer(minLength: geo.size.width * 0.35) // Hack to fix spacing
            }
        }
    }

    var timer: some View {
        Image(systemName: "timer")
            .resizable()
            .frame(width: 12.0, height: 12.0)
    }
}
