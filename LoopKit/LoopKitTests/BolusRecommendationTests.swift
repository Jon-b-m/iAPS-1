import HealthKit
import XCTest

@testable import LoopKit

class BolusRecommendationNoticeCodableTests: XCTestCase {
    func testCodableGlucoseBelowSuspendThreshold() throws {
        let glucoseValue = SimpleGlucoseValue(
            startDate: dateFormatter.date(from: "2020-05-14T22:14:16Z")!,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 65.0)
        )
        try assertBolusRecommendationNoticeCodable(
            .glucoseBelowSuspendThreshold(minGlucose: glucoseValue),
            encodesJSON: """
            {
              "bolusRecommendationNotice" : {
                "glucoseBelowSuspendThreshold" : {
                  "minGlucose" : {
                    "endDate" : "2020-05-14T22:14:16Z",
                    "quantity" : 65,
                    "quantityUnit" : "mg/dL",
                    "startDate" : "2020-05-14T22:14:16Z"
                  }
                }
              }
            }
            """
        )
    }

    func testCodableCurrentGlucoseBelowTarget() throws {
        let glucoseValue = SimpleGlucoseValue(
            startDate: dateFormatter.date(from: "2020-05-14T22:20:16Z")!,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 85.0)
        )
        try assertBolusRecommendationNoticeCodable(
            .currentGlucoseBelowTarget(glucose: glucoseValue),
            encodesJSON: """
            {
              "bolusRecommendationNotice" : {
                "currentGlucoseBelowTarget" : {
                  "glucose" : {
                    "endDate" : "2020-05-14T22:20:16Z",
                    "quantity" : 85,
                    "quantityUnit" : "mg/dL",
                    "startDate" : "2020-05-14T22:20:16Z"
                  }
                }
              }
            }
            """
        )
    }

    func testCodablePredictedGlucoseBelowTarget() throws {
        let glucoseValue = SimpleGlucoseValue(
            startDate: dateFormatter.date(from: "2020-05-14T22:38:16Z")!,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 80.0)
        )
        try assertBolusRecommendationNoticeCodable(
            .predictedGlucoseBelowTarget(minGlucose: glucoseValue),
            encodesJSON: """
            {
              "bolusRecommendationNotice" : {
                "predictedGlucoseBelowTarget" : {
                  "minGlucose" : {
                    "endDate" : "2020-05-14T22:38:16Z",
                    "quantity" : 80,
                    "quantityUnit" : "mg/dL",
                    "startDate" : "2020-05-14T22:38:16Z"
                  }
                }
              }
            }
            """
        )
    }

    func testCodablePredictedGlucoseInRange() throws {
        try assertBolusRecommendationNoticeCodable(
            .predictedGlucoseInRange,
            encodesJSON: """
            {
              "bolusRecommendationNotice" : "predictedGlucoseInRange"
            }
            """
        )
    }

    func testCodableAllGlucoseBelowTarget() throws {
        let glucoseValue = SimpleGlucoseValue(
            startDate: dateFormatter.date(from: "2020-05-14T22:38:16Z")!,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 80.0)
        )
        try assertBolusRecommendationNoticeCodable(
            .allGlucoseBelowTarget(minGlucose: glucoseValue),
            encodesJSON: """
            {
              "bolusRecommendationNotice" : {
                "allGlucoseBelowTarget" : {
                  "minGlucose" : {
                    "endDate" : "2020-05-14T22:38:16Z",
                    "quantity" : 80,
                    "quantityUnit" : "mg/dL",
                    "startDate" : "2020-05-14T22:38:16Z"
                  }
                }
              }
            }
            """
        )
    }

    private func assertBolusRecommendationNoticeCodable(
        _ original: BolusRecommendationNotice,
        encodesJSON string: String
    ) throws {
        let data = try encoder.encode(TestContainer(bolusRecommendationNotice: original))
        XCTAssertEqual(String(data: data, encoding: .utf8), string)
        let decoded = try decoder.decode(TestContainer.self, from: data)
        XCTAssertEqual(decoded.bolusRecommendationNotice, original)
    }

    private let dateFormatter = ISO8601DateFormatter()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private struct TestContainer: Codable, Equatable {
        let bolusRecommendationNotice: BolusRecommendationNotice
    }
}

extension BolusRecommendationNotice: Equatable {
    public static func == (lhs: BolusRecommendationNotice, rhs: BolusRecommendationNotice) -> Bool {
        switch (lhs, rhs) {
        case let
            (.allGlucoseBelowTarget(lhsGlucoseValue), .allGlucoseBelowTarget(rhsGlucoseValue)),
             let
                 (.currentGlucoseBelowTarget(lhsGlucoseValue), .currentGlucoseBelowTarget(rhsGlucoseValue)),
             let (.glucoseBelowSuspendThreshold(lhsGlucoseValue), .glucoseBelowSuspendThreshold(rhsGlucoseValue)),
             let
                 (.predictedGlucoseBelowTarget(lhsGlucoseValue), .predictedGlucoseBelowTarget(rhsGlucoseValue)):
            return lhsGlucoseValue.startDate == rhsGlucoseValue.startDate &&
                lhsGlucoseValue.endDate == rhsGlucoseValue.endDate &&
                lhsGlucoseValue.quantity == rhsGlucoseValue.quantity
        case (.predictedGlucoseInRange, .predictedGlucoseInRange):
            return true
        default:
            return false
        }
    }
}
