import Foundation

public protocol AnalyticsService: Service {
    func recordAnalyticsEvent(_ name: String, withProperties properties: [AnyHashable: Any]?, outOfSession: Bool)

    func recordIdentify(_ property: String, value: String)

    func recordIdentify(_ property: String, array: [String])
}
