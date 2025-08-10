import Foundation

protocol CaseCountable: RawRepresentable {}

extension CaseCountable where RawValue == Int {
    static var count: Int {
        var i: Int = 0
        while let new = Self(rawValue: i) { i = new.rawValue.advanced(by: 1) }
        return i
    }
}
