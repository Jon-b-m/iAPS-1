import os.lock

public class Locked<T> {
    private var _lock: UnfairLock
    private var _value: T

    public init(_ value: T) {
        _lock = UnfairLock()
        _value = value
    }

    public var value: T {
        get {
            _lock.withLock { _value }
        }
        set {
            _lock.withLock {
                _value = newValue
            }
        }
    }

    @discardableResult public func mutate(_ changes: (_ value: inout T) -> Void) -> T {
        _lock.withLock {
            changes(&_value)
            return _value
        }
    }
}
