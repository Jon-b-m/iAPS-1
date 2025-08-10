import Foundation
import HealthKit

class HKAnchoredObjectQueryMock: HKAnchoredObjectQuery {
    let anchor: HKQueryAnchor?
    let resultsHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void

    @available(iOS 15.0, *) override init(
        queryDescriptors: [HKQueryDescriptor],
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler handler: @escaping (
            HKAnchoredObjectQuery,
            [HKSample]?,
            [HKDeletedObject]?,
            HKQueryAnchor?,
            Error?
        ) -> Void
    ) {
        resultsHandler = handler
        self.anchor = anchor
        super.init(queryDescriptors: queryDescriptors, anchor: anchor, limit: limit, resultsHandler: handler)
    }

    override init(
        type: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler handler: @escaping (
            HKAnchoredObjectQuery,
            [HKSample]?,
            [HKDeletedObject]?,
            HKQueryAnchor?,
            Error?
        ) -> Void
    ) {
        resultsHandler = handler
        self.anchor = anchor
        super.init(type: type, predicate: predicate, anchor: anchor, limit: limit, resultsHandler: handler)
    }
}
