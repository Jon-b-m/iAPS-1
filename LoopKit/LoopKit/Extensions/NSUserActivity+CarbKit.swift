import Foundation

// FIXME: this class should be in Loop now that the carb entry flow is there
/// Conveniences for activity handoff and restoration of creating a carb entry
public extension NSUserActivity {
    static let newCarbEntryActivityType = "NewCarbEntry"

    static let newCarbEntryUserInfoKey = "NewCarbEntry"
    static let carbEntryIsMissedMealUserInfoKey = "CarbEntryIsMissedMeal"

    class func forNewCarbEntry() -> NSUserActivity {
        let activity = NSUserActivity(activityType: newCarbEntryActivityType)
        activity.requiredUserInfoKeys = []
        return activity
    }

    func update(from entry: NewCarbEntry?, isMissedMeal: Bool = false) {
        if let rawValue = entry?.rawValue {
            addUserInfoEntries(from: [
                NSUserActivity.newCarbEntryUserInfoKey: rawValue,
                NSUserActivity.carbEntryIsMissedMealUserInfoKey: isMissedMeal
            ])
        } else {
            userInfo = nil
        }
    }

    var newCarbEntry: NewCarbEntry? {
        guard let rawValue = userInfo?[NSUserActivity.newCarbEntryUserInfoKey] as? NewCarbEntry.RawValue else {
            return nil
        }

        return NewCarbEntry(rawValue: rawValue)
    }

    var entryisMissedMeal: Bool {
        guard newCarbEntry != nil else {
            return false
        }

        return userInfo?[NSUserActivity.carbEntryIsMissedMealUserInfoKey] as? Bool ?? false
    }
}
