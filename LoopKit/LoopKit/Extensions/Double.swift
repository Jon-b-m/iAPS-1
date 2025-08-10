import Foundation

extension Double: RawRepresentable {
    public typealias RawValue = Double

    public init?(rawValue: RawValue) {
        self = rawValue
    }

    public var rawValue: RawValue {
        self
    }
}

infix operator =~: ComparisonPrecedence

extension Double {
    static func =~ (lhs: Double, rhs: Double) -> Bool {
        fabs(lhs - rhs) < Double.ulpOfOne
    }
}
