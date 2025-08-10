import SwiftUI

public struct CardStack: View {
    var cards: [Card?]
    var spacing: CGFloat?

    public init(cards: [Card?], spacing: CGFloat? = nil) {
        self.cards = cards
        self.spacing = spacing
    }

    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(self.cards.indices, id: \.self) { index in
                self.cards[index]
            }
        }
        .padding(.bottom)
    }
}

extension CardStack {
    init(reducing stacks: [CardStack]) {
        cards = stacks.flatMap(\.cards)
        spacing = nil
    }
}

extension CardStack {
    private init(_ other: Self, spacing: CGFloat? = nil) {
        cards = other.cards
        self.spacing = spacing ?? other.spacing
    }

    func spacing(_ spacing: CGFloat?) -> Self { Self(self, spacing: spacing) }
}
