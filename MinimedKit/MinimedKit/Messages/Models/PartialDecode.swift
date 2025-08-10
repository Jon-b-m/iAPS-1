import Foundation

public enum PartialDecode<T1, T2> {
    case known(T1)
    case unknown(T2)
}
