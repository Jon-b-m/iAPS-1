func fractionThrough<Metric: FloatingPoint>(
    _ value: Metric,
    in range: ClosedRange<Metric>,
    using transform: (Metric) -> Metric = { $0 }
) -> Metric {
    let transformedLowerBound = transform(range.lowerBound)
    return (transform(value) - transformedLowerBound) / (transform(range.upperBound) - transformedLowerBound)
}

func interpolatedValue<Metric: FloatingPoint>(
    at fraction: Metric,
    through range: ClosedRange<Metric>
) -> Metric {
    fraction * (range.upperBound - range.lowerBound) + range.lowerBound
}
