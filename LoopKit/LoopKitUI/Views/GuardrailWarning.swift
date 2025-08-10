import LoopKit
import SwiftUI

public struct GuardrailWarning: View {
    private enum CrossedThresholds {
        case one(SafetyClassification.Threshold)
        case oneOrMore([SafetyClassification.Threshold])
    }

    private var therapySetting: TherapySetting
    private var title: Text
    private var crossedThresholds: CrossedThresholds
    private var captionOverride: Text?

    public init(
        therapySetting: TherapySetting,
        title: Text,
        threshold: SafetyClassification.Threshold,
        caption: Text? = nil
    ) {
        self.therapySetting = therapySetting
        self.title = title
        crossedThresholds = .one(threshold)
        captionOverride = caption
    }

    public init(
        therapySetting: TherapySetting,
        title: Text,
        thresholds: [SafetyClassification.Threshold],
        caption: Text? = nil
    ) {
        precondition(!thresholds.isEmpty)
        self.therapySetting = therapySetting
        self.title = title
        crossedThresholds = .oneOrMore(thresholds)
        captionOverride = caption
    }

    public var body: some View {
        WarningView(title: title, caption: caption, severity: severity)
    }

    private var severity: WarningSeverity {
        switch crossedThresholds {
        case let .one(threshold):
            return threshold.severity
        case let .oneOrMore(thresholds):
            return thresholds.lazy.map(\.severity).max()!
        }
    }

    private var caption: Text {
        if let caption = captionOverride {
            return caption
        }

        switch crossedThresholds {
        case let .one(threshold):
            return captionForThreshold(threshold)
        case let .oneOrMore(thresholds):
            if thresholds.count == 1, let threshold = thresholds.first {
                return captionForThreshold(threshold)
            } else {
                return captionForThresholds()
            }
        }
    }

    private func captionForThreshold(_ threshold: SafetyClassification.Threshold) -> Text {
        switch threshold {
        case .belowRecommended,
             .minimum:
            return Text(therapySetting.guardrailCaptionForLowValue)
        case .aboveRecommended,
             .maximum:
            return Text(therapySetting.guardrailCaptionForHighValue)
        }
    }

    private func captionForThresholds() -> Text {
        Text(therapySetting.guardrailCaptionForOutsideValues)
    }
}

private extension SafetyClassification.Threshold {
    var severity: WarningSeverity {
        switch self {
        case .aboveRecommended,
             .belowRecommended:
            return .default
        case .maximum,
             .minimum:
            return .critical
        }
    }
}
