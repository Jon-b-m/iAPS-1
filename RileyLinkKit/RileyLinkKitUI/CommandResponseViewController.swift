import Foundation
import LoopKitUI
import RileyLinkBLEKit

extension CommandResponseViewController {
    typealias T = CommandResponseViewController

    static func getStatistics(device: RileyLinkDevice) -> T {
        T { (completionHandler) -> String in
            device.runSession(withName: "Get Statistics") { session in
                let response: String

                do {
                    let stats = try session.getRileyLinkStatistics()
                    response = String(describing: stats)
                } catch {
                    response = String(describing: error)
                }

                DispatchQueue.main.async {
                    completionHandler(response)
                }
            }

            return LocalizedString("Get Statistics…", comment: "Progress message for getting statistics.")
        }
    }

    static func setDiagnosticLEDMode(device: RileyLinkDevice, mode: RileyLinkLEDMode) -> T {
        T { (completionHandler) -> String in
            device.setDiagnosticeLEDModeForBLEChip(mode)
            device.runSession(withName: "Update diagnostic LED mode") { session in
                let response: String
                do {
                    try session.setCCLEDMode(mode)
                    switch mode {
                    case .on:
                        response = "Diagnostic mode enabled"
                    default:
                        response = "Diagnostic mode disabled"
                    }
                } catch {
                    response = String(describing: error)
                }

                DispatchQueue.main.async {
                    completionHandler(response)
                }
            }

            return LocalizedString("Updating diagnostic LEDs mode", comment: "Progress message for changing diagnostic LED mode")
        }
    }
}
