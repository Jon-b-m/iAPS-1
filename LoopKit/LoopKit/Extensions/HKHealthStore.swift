import HealthKit

protocol HKSampleQueryTestable {
    func executeSampleQuery(
        for type: HKSampleType,
        matching predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) -> Void
    )
}
