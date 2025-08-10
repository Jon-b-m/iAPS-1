public extension MutableCollection {
    mutating func mutateEach(_ body: (inout Element) throws -> Void) rethrows {
        var index = startIndex
        while index != endIndex {
            try body(&self[index])
            formIndex(after: &index)
        }
    }
}
