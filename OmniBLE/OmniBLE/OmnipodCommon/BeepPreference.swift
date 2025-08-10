import Foundation
import SwiftUI

public enum BeepPreference: Int, CaseIterable {
    case silent
    case manualCommands
    case extended

    var title: String {
        switch self {
        case .silent:
            return LocalizedString("Disabled", comment: "Title string for BeepPreference.silent")
        case .manualCommands:
            return LocalizedString("Enabled", comment: "Title string for BeepPreference.manualCommands")
        case .extended:
            return LocalizedString("Extended", comment: "Title string for BeepPreference.extended")
        }
    }

    var description: String {
        // This picks up the DefaultValue from LoopKit, not the CFBundleDisplayName
        // @Environment(\.appName) var appName
        // ToDo - insert the appName properly
        let appName: String = "the app"

        switch self {
        case .silent:
            return LocalizedString("No confidence reminders are used.", comment: "Description for BeepPreference.silent")
        case .manualCommands:
            return String(
                format: LocalizedString(
                    "Confidence reminders will sound for commands you initiate, like bolus, cancel bolus, suspend, resume, save notification reminders, etc. When %1$@ automatically adjusts delivery, no confidence reminders are used.",
                    comment: "Description for BeepPreference.manualCommands (1: appName)"
                ),
                appName
            )
        case .extended:
            return String(
                format: LocalizedString(
                    "Confidence reminders will sound when %1$@ automatically adjusts delivery as well as for commands you initiate.",
                    comment: "Description for BeepPreference.extended (1: appName)"
                ),
                appName
            )
        }
    }

    var shouldBeepForManualCommand: Bool {
        self == .extended || self == .manualCommands
    }

    var shouldBeepForAutomaticCommands: Bool {
        self == .extended
    }

    func shouldBeepForCommand(automatic: Bool) -> Bool {
        if automatic {
            return shouldBeepForAutomaticCommands
        } else {
            return shouldBeepForManualCommand
        }
    }
}
