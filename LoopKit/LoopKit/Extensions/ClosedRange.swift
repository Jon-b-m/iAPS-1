extension ClosedRange {
    func expandedToInclude(_ value: Bound) -> ClosedRange {
        if value < lowerBound {
            return value ... upperBound
        } else if value > upperBound {
            return lowerBound ... value
        } else {
            return self
        }
    }
}
