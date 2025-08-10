import UIKit

class ThumbView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .white
        makeRound()
        configureDropShadow()
    }

    private func makeRound() {
        layer.cornerRadius = min(frame.width, frame.height) / 2
    }

    private func configureDropShadow() {
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: -2, height: 0)
    }
}
