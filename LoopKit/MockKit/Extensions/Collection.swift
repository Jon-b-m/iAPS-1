import Dispatch
import LoopKit

extension Collection {
    func asyncMap<NewElement>(
        _ asyncTransform: (
            _ element: Element,
            _ completion: @escaping (NewElement) -> Void
        ) -> Void,
        notifyingOn queue: DispatchQueue = .global(),
        completion: @escaping ([NewElement]) -> Void
    ) {
        let result = Locked([NewElement?](repeating: nil, count: count))
        let group = DispatchGroup()

        for (resultIndex, element) in enumerated() {
            group.enter()
            asyncTransform(element) { newElement in
                result.value[resultIndex] = newElement
                group.leave()
            }
        }

        group.notify(queue: queue) {
            let transformed = result.value.map { $0! }
            completion(transformed)
        }
    }

    /// Returns a sequence containing adjacent pairs of elements in the ordered collection.
    func adjacentPairs() -> Zip2Sequence<Self, SubSequence> {
        zip(self, dropFirst())
    }
}
