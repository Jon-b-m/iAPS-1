import TidepoolKit

protocol TypedDatum {
    static var resolvedType: String { get }
}

protocol IdentifiableDatum {
    var syncIdentifierAsString: String { get }
}

extension IdentifiableDatum {
    func datumId(for userId: String) -> String {
        datumId(for: userId, resolvedIdentifier: resolvedIdentifier)
    }

    func datumId<T: TypedDatum>(for userId: String, type: T.Type) -> String {
        datumId(for: userId, resolvedIdentifier: resolvedIdentifier(for: type))
    }

    private func datumId(for userId: String, resolvedIdentifier: String) -> String {
        "\(userId):\(resolvedIdentifier)".md5hash!
    }

    func datumOrigin(for resolvedIdentifier: String, hostIdentifier: String, hostVersion: String) -> TOrigin {
        TOrigin(
            id: resolvedIdentifier,
            name: hostIdentifier,
            version: hostVersion,
            type: .application
        )
    }

    var datumSelector: TDatum.Selector {
        datumSelector(for: resolvedIdentifier)
    }

    func datumSelector<T: TypedDatum>(for type: T.Type) -> TDatum.Selector {
        datumSelector(for: resolvedIdentifier(for: type))
    }

    private func datumSelector(for resolvedIdentifier: String) -> TDatum.Selector {
        TDatum.Selector(origin: TDatum.Selector.Origin(id: resolvedIdentifier))
    }

    var resolvedIdentifier: String {
        syncIdentifierAsString
    }

    func resolvedIdentifier<T: TypedDatum>(for type: T.Type) -> String {
        "\(resolvedIdentifier):\(type.resolvedType)"
    }
}
