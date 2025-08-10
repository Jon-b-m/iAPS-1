extension Dictionary {
    func compactMapValuesWithKeys<NewValue>(_ transform: (Element) throws -> NewValue?) rethrows -> [Key: NewValue] {
        try reduce(into: [:]) { result, element in
            if let newValue = try transform(element) {
                result[element.key] = newValue
            }
        }
    }
}
