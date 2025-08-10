import Foundation
import HealthKit
@testable import LoopKit
import XCTest

class MockHKObserverQuery: HKObserverQuery {
    var updateHandler: ((HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void)?
    override init(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        updateHandler: @escaping (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void
    )
    {
        super.init(sampleType: sampleType, predicate: predicate, updateHandler: updateHandler)
        self.updateHandler = updateHandler
    }

    override init(
        queryDescriptors: [HKQueryDescriptor],
        updateHandler: @escaping (HKObserverQuery, Set<HKSampleType>?, @escaping HKObserverQueryCompletionHandler, Error?) -> Void
    ) {
        super.init(queryDescriptors: queryDescriptors, updateHandler: updateHandler)
    }
}

class MockHKAnchoredObjectQuery: HKAnchoredObjectQuery {
    var resultsHandler: ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void)?
    var anchor: HKQueryAnchor?
    override init(
        type: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler handler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void
    )
    {
        super.init(type: type, predicate: predicate, anchor: anchor, limit: limit, resultsHandler: handler)
        resultsHandler = handler
        self.anchor = anchor
    }

    override init(
        queryDescriptors: [HKQueryDescriptor],
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler handler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void
    ) {
        super.init(queryDescriptors: queryDescriptors, anchor: anchor, limit: limit, resultsHandler: handler)
    }
}

class HKHealthStoreMock: HKHealthStoreProtocol {
    func stop(_: HKQuery) {}

    func enableBackgroundDelivery(for _: HKObjectType, frequency _: HKUpdateFrequency) async throws {
        didEnableBackgroundDelivery = true
    }

    func cachedPreferredUnits(for quantityTypeIdentifier: HKQuantityTypeIdentifier) async -> HKUnit? {
        unitsCache[quantityTypeIdentifier]
    }

    var unitsCache: [HKQuantityTypeIdentifier: HKUnit] = [
        .bloodGlucose: .milligramsPerDeciliter,
        .insulinDelivery: .internationalUnit(),
        .dietaryCarbohydrates: .gram()
    ]

    var saveError: Error?
    var didEnableBackgroundDelivery: Bool = false
    var deleteError: Error?
    var queryResults: (samples: [HKSample]?, error: Error?)?
    var observerQuery: HKObserverQuery?
    var anchoredObjectQuery: HKAnchoredObjectQuery?
    var authorizationStatus: HKAuthorizationStatus?
    let authorizationRequestUserResponse: Result<Bool, Error> = .success(true)

    var observerQueryStartedExpectation: XCTestExpectation?
    var anchorQueryStartedExpectation: XCTestExpectation?

    private var saveHandler: ((_ objects: [HKObject], _ success: Bool, _ error: Error?) -> Void)?
    private var deleteObjectsHandler: ((
        _ objectType: HKObjectType,
        _ predicate: NSPredicate,
        _ success: Bool,
        _ count: Int,
        _ error: Error?
    ) -> Void)?

    let queue = DispatchQueue(label: "HKHealthStoreMock")

    func execute(_ query: HKQuery) {
        switch query {
        case let q as HKObserverQuery:
            observerQuery = q
            observerQueryStartedExpectation?.fulfill()
        case let q as HKAnchoredObjectQuery:
            anchoredObjectQuery = q
            anchorQueryStartedExpectation?.fulfill()
        default:
            print("Unhandled query: \(query)")
        }
    }

    func save(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void) {
        queue.async {
            self.saveHandler?([object], self.saveError == nil, self.saveError)
            completion(self.saveError == nil, self.saveError)
        }
    }

    func save(_ objects: [HKObject], withCompletion completion: @escaping (Bool, Error?) -> Void) {
        queue.async {
            self.saveHandler?(objects, self.saveError == nil, self.saveError)
            completion(self.saveError == nil, self.saveError)
        }
    }

    func delete(_: [HKObject], withCompletion completion: @escaping (Bool, Error?) -> Void) {
        queue.async {
            completion(self.deleteError == nil, self.deleteError)
        }
    }

    func deleteObjects(
        of objectType: HKObjectType,
        predicate: NSPredicate,
        withCompletion completion: @escaping (Bool, Int, Error?) -> Void
    ) {
        queue.async {
            self.deleteObjectsHandler?(objectType, predicate, self.deleteError == nil, 0, self.deleteError)
            completion(self.deleteError == nil, 0, self.deleteError)
        }
    }

    func setSaveHandler(_ saveHandler: ((_ objects: [HKObject], _ success: Bool, _ error: Error?) -> Void)?) {
        queue.sync {
            self.saveHandler = saveHandler
        }
    }

    func requestAuthorization(
        toShare _: Set<HKSampleType>?,
        read _: Set<HKObjectType>?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        switch authorizationRequestUserResponse {
        case let .success(authorized):
            authorizationStatus = authorized ? .sharingAuthorized : .sharingDenied
            DispatchQueue.main.async {
                completion(true, nil)
            }
        case let .failure(error):
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }

    func authorizationStatus(for _: HKObjectType) -> HKAuthorizationStatus {
        authorizationStatus ?? .notDetermined
    }

    func setDeletedObjectsHandler(_ deleteObjectsHandler: ((
        _ objectType: HKObjectType,
        _ predicate: NSPredicate,
        _ success: Bool,
        _ count: Int,
        _ error: Error?
    ) -> Void)?) {
        queue.sync {
            self.deleteObjectsHandler = deleteObjectsHandler
        }
    }
}

extension HKHealthStoreMock: HKSampleQueryTestable {
    func executeSampleQuery(
        for type: HKSampleType,
        matching predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) -> Void
    ) {
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors,
            resultsHandler: resultsHandler
        )

        guard let results = queryResults else {
            execute(query)
            return
        }

        queue.async {
            resultsHandler(query, results.samples, results.error)
        }
    }
}
