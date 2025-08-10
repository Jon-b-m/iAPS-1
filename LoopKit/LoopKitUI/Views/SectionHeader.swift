import SwiftUI

public struct SectionHeader: View {
    var label: String
    var style: Style

    public enum Style {
        case regular
        case tight
    }

    public init(label: String, style: Style = .default) {
        self.label = label
        self.style = style
    }

    public var body: some View {
        // iOS 14 puts section headers in all-caps by default.  This un-does that.
        content.textCase(nil)
    }

    @ViewBuilder private var content: some View {
        Text(label)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.leading, style == .tight ? -10 : 0)
    }
}

private struct HorizontalSizeClassOverrideHelper: HorizontalSizeClassOverride {}
public extension SectionHeader.Style {
    static let `default`: SectionHeader.Style = {
        .regular
    }()
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(label: "Header Label")
    }
}
