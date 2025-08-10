struct EmojiSection {
    let title: String
    let items: [String]
    let indexSymbol: String
}

protocol EmojiDataSource {
    var sections: [EmojiSection] { get }
}

public enum EmojiDataSourceType {
    case food
    case override

    func dataSource() -> EmojiDataSource {
        switch self {
        case .food:
            return FoodEmojiDataSource()
        case .override:
            return OverrideEmojiDataSource()
        }
    }
}
