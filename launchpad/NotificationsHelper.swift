import UserNotifications

struct NotificationsHelper {
    static let center = UNUserNotificationCenter.current()

    static func askForPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
    }

    static func present(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Lebkuchen FM"
        content.body = message
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request, withCompletionHandler: nil)
        DispatchQueue.global().asyncAfter(deadline: .now() + 60) { [weak center] in
            center?.removeDeliveredNotifications(withIdentifiers: [request.identifier])
        }
    }
}
