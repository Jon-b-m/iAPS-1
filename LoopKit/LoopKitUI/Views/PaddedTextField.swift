import UIKit

class PaddedTextField: UITextField {
    @IBInspectable var textInset: CGSize = .zero {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    private var textInsets: UIEdgeInsets {
        UIEdgeInsets(top: textInset.height, left: textInset.width, bottom: textInset.height, right: textInset.width)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
}
