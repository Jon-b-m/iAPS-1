import CGMBLEKit
import Foundation

class CommandQueue {
    private var list = [Command]()
    private var lock = os_unfair_lock()

    func enqueue(_ element: Command) {
        os_unfair_lock_lock(&lock)
        list.append(element)
        os_unfair_lock_unlock(&lock)
    }

    func dequeue() -> Command? {
        os_unfair_lock_lock(&lock)
        defer {
            os_unfair_lock_unlock(&lock)
        }
        if !list.isEmpty {
            return list.removeFirst()
        } else {
            return nil
        }
    }
}
