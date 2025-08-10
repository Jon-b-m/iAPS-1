import UIKit

public class CustomInputTextField: UITextField {
    public var customInput: UIInputViewController?

    override public var inputViewController: UIInputViewController? {
        customInput
    }
}
