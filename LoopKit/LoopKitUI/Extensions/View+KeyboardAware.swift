import SwiftUI

// NOTE: In iOS 14, keyboard management is handled automatically in SwiftUI.
public extension View {
    func onKeyboardStateChange(perform updateForKeyboardState: @escaping (_ keyboardHeight: Keyboard.State) -> Void)
        -> some View
    {
        onReceive(Keyboard.shared.$state, perform: updateForKeyboardState)
    }

    func keyboardAware() -> some View {
        modifier(KeyboardAware())
    }
}

private struct KeyboardAware: ViewModifier {
    @State var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .edgesIgnoringSafeArea(keyboardHeight > 0 ? .bottom : [])
            .onKeyboardStateChange { state in
                if state.height == 0 {
                    // Only animate the transition as the keyboard comes up; animating the opposite direction is jittery.
                    self.keyboardHeight = 0
                } else {
                    withAnimation(.easeInOut(duration: state.animationDuration)) {
                        self.keyboardHeight = state.height
                    }
                }
            }
    }
}
