import Foundation

public protocol CompletionDelegate: AnyObject {
    func completionNotifyingDidComplete(_ object: CompletionNotifying)
}

public protocol CompletionNotifying {
    var completionDelegate: CompletionDelegate? { set get }
}
