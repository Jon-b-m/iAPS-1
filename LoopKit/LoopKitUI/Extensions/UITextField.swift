import UIKit

extension UITextField {
    func selectAll() {
        dispatchPrecondition(condition: .onQueue(.main))
        selectedTextRange = textRange(from: beginningOfDocument, to: endOfDocument)
    }

    func moveCursorToEnd() {
        dispatchPrecondition(condition: .onQueue(.main))
        let newPosition = endOfDocument
        selectedTextRange = textRange(from: newPosition, to: newPosition)
    }

    func moveCursorToBeginning() {
        dispatchPrecondition(condition: .onQueue(.main))
        let newPosition = beginningOfDocument
        selectedTextRange = textRange(from: newPosition, to: newPosition)
    }
}
