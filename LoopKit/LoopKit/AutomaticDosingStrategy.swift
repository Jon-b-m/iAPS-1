import Foundation

public enum AutomaticDosingStrategy: Int, CaseIterable, Codable {
    case tempBasalOnly
    case automaticBolus
}
