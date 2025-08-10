import Foundation

public class ButtonPressCarelinkMessageBody: CarelinkLongMessageBody {
    public enum ButtonType: UInt8 {
        case act = 0x02
        case esc = 0x01
        case down = 0x04
        case up = 0x03
        case easy = 0x00
    }

    public convenience init(buttonType: ButtonType) {
        let numArgs = 1
        let data = Data(hexadecimalString: String(format: "%02x%02x", numArgs, buttonType.rawValue))!

        self.init(rxData: data)!
    }
}
