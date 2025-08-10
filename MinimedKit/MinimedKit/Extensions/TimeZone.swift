import Foundation

extension TimeZone {
    static var currentFixed: TimeZone {
        TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!
    }

    var fixed: TimeZone {
        TimeZone(secondsFromGMT: secondsFromGMT())!
    }
}
