import SwiftUI

struct SegmentedGaugeBar: UIViewRepresentable {
    let insulinNeedsScaler: Double
    let startColor: UIColor
    let endColor: UIColor

    init(insulinNeedsScaler: Double, startColor: UIColor, endColor: UIColor) {
        self.insulinNeedsScaler = insulinNeedsScaler
        self.startColor = startColor
        self.endColor = endColor
    }

    func makeUIView(context _: Context) -> SegmentedGaugeBarView {
        let view = SegmentedGaugeBarView()
        view.numberOfSegments = 2
        view.startColor = startColor
        view.endColor = endColor
        view.borderWidth = 1
        view.borderColor = .systemGray
        view.progress = insulinNeedsScaler
        view.isUserInteractionEnabled = false // Don't allow slider to change value based on user taps
        return view
    }

    func updateUIView(_: SegmentedGaugeBarView, context _: Context) {}
}
