import UIKit

class ParagraphView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()

        textContainer.lineFragmentPadding = 0

        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.paragraphSpacing = 10

        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.preferredFont(forTextStyle: .body)
            ]
        )
    }
}
