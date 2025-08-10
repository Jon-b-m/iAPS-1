import UIKit

class TextField: UITextField {
    private let textInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInset)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInset)
    }
}
