import LoopKit
import SwiftUI

public struct CarbRatioInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appName) private var appName

    public init(
        onExit: (() -> Void)?,
        mode: SettingsPresentationMode = .acceptanceFlow
    ) {
        self.onExit = onExit
        self.mode = mode
    }

    public var body: some View {
        InformationView(
            title: Text(TherapySetting.carbRatio.title),
            informationalContent: { text },
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(TherapySetting.carbRatio.descriptiveText(appName: appName))
            Text(LocalizedString(
                "You can add different carb ratios for different times of day by using the ➕.",
                comment: "Description of how to add a ratio"
            ))
        }
        .accentColor(.secondary)
    }
}
