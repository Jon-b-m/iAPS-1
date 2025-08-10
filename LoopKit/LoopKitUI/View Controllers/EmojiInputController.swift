import UIKit

public class EmojiInputController: UIInputViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    IdentifiableClass
{
    @IBOutlet private var collectionView: UICollectionView!

    @IBOutlet private var sectionIndex: UIStackView!

    public weak var delegate: EmojiInputControllerDelegate?

    var emojis: EmojiDataSource!

    static func instance(withEmojis emojis: EmojiDataSource) -> EmojiInputController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: className, bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! EmojiInputController
        controller.emojis = emojis
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        inputView = view as? UIInputView
        inputView?.allowsSelfSizing = true
        view.translatesAutoresizingMaskIntoConstraints = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.sectionFootersPinToVisibleBounds = true
        }

        setupSectionIndex()

        // Scroll to medium absorption
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 1), at: .left, animated: false)
        }
    }

    private func setupSectionIndex() {
        sectionIndex.removeAllArrangedSubviews()

        for section in emojis.sections {
            let label = UILabel(frame: .zero)
            label.text = section.indexSymbol
            sectionIndex.addArrangedSubview(label)
        }
    }

    @IBOutlet var deleteButton: UIButton! {
        didSet {
            let image = UIImage(systemName: "delete.left", compatibleWith: traitCollection)
            deleteButton.setImage(image, for: .normal)
        }
    }

    // MARK: - Actions

    @IBAction func switchKeyboard(_: Any) {
        delegate?.emojiInputControllerDidAdvanceToStandardInputMode(self)
    }

    @IBAction func deleteBackward(_: Any) {
        inputView?.playInputClick​()
        textDocumentProxy.deleteBackward()
    }

    @IBAction func indexTouched(_ sender: UIGestureRecognizer) {
        let xLocation = max(0, sender.location(in: sectionIndex).x / sectionIndex.frame.width)
        let items = sectionIndex.arrangedSubviews.count
        let section = min(items - 1, Int(xLocation * CGFloat(items)))

        collectionView.scrollToItem(at: IndexPath(item: 0, section: section), at: .left, animated: false)
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in _: UICollectionView) -> Int {
        emojis.sections.count
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojis.sections[section].items.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: kind == UICollectionView.elementKindSectionHeader ? EmojiInputHeaderView.className : "Footer",
            for: indexPath
        )

        if let cell = cell as? EmojiInputHeaderView {
            cell.titleLabel.text = emojis.sections[indexPath.section].title.localizedUppercase
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiInputCell.className,
            for: indexPath
        ) as! EmojiInputCell

        cell.label.text = emojis.sections[indexPath.section].items[indexPath.row]

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        inputView?.playInputClick​()
        textDocumentProxy.insertText(emojis.sections[indexPath.section].items[indexPath.row])

        delegate?.emojiInputControllerDidSelectItemInSection(indexPath.section)
    }
}

public protocol EmojiInputControllerDelegate: AnyObject {
    func emojiInputControllerDidAdvanceToStandardInputMode(_ controller: EmojiInputController)

    func emojiInputControllerDidSelectItemInSection(_ section: Int)
}

// MARK: - Default Implementations

public extension EmojiInputControllerDelegate {
    func emojiInputControllerDidSelectItemInSection(_: Int) {}
}

extension UIInputView: UIInputViewAudioFeedback {
    public var enableInputClicksWhenVisible: Bool { true }

    func playInputClick​() {
        let device = UIDevice.current
        device.playInputClick()
    }
}

private extension UIStackView {
    func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}
