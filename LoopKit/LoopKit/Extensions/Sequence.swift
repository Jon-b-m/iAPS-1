extension Sequence {
    func range<Metric: Comparable>(of metricForElement: (Element) throws -> Metric) rethrows -> ClosedRange<Metric>? {
        try lazy.map(metricForElement).reduce(nil) { range, metric in
            if let range = range {
                return range.expandedToInclude(metric)
            } else {
                return metric ... metric
            }
        }
    }
}
