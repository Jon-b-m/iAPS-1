import UIKit
import UserNotifications

class CompletionViewController: UITableViewController {
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIApplication.shared.applicationState == .background {
            let content = UNMutableNotificationContent()
            content.badge = 1
            content.title = NSLocalizedString(
                "Transmitter Reset Complete",
                comment: "Notification title for background completion notification"
            )
            content.body = textView.text
            content.sound = .default

            let request = UNNotificationRequest(identifier: "Completion", content: content, trigger: nil)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    override func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool {
        false
    }

    override func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
        nil
    }
}
