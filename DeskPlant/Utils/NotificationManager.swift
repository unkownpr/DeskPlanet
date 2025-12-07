import Foundation
import UserNotifications
import AppKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private var soundEnabled = true

    override init() {
        super.init()
        notificationCenter.delegate = self
        loadSettings()
    }

    // MARK: - Authorization
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Send Notifications
    func sendNotification(title: String, body: String, sound: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if sound && soundEnabled {
            content.sound = .default
        }

        // Add action buttons
        let openAction = UNNotificationAction(
            identifier: "OPEN_ACTION",
            title: "Open DeskPlant",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: "TIMER_COMPLETE",
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "TIMER_COMPLETE"

        // Trigger immediately
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Reminder
    func scheduleReminder(after interval: TimeInterval, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if soundEnabled {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "reminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cancel Notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    func cancelReminders() {
        notificationCenter.getPendingNotificationRequests { requests in
            let reminderIdentifiers = requests
                .filter { $0.identifier.starts(with: "reminder-") }
                .map { $0.identifier }

            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        }
    }

    // MARK: - Settings
    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notificationSoundEnabled")
    }

    private func loadSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: "notificationSoundEnabled")
        if UserDefaults.standard.object(forKey: "notificationSoundEnabled") == nil {
            soundEnabled = true // Default to enabled
        }
    }

    // MARK: - Play Sound
    func playSound(named soundName: String = "Glass") {
        guard soundEnabled else { return }
        NSSound(named: soundName)?.play()
    }

    func playSuccessSound() {
        playSound(named: "Glass")
    }

    func playBreakSound() {
        playSound(named: "Submarine")
    }

    func playWarningSound() {
        playSound(named: "Funk")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "OPEN_ACTION":
            // Show the app (menu bar controller will handle this)
            NotificationCenter.default.post(name: NSNotification.Name("ShowApp"), object: nil)

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            NotificationCenter.default.post(name: NSNotification.Name("ShowApp"), object: nil)

        default:
            break
        }

        completionHandler()
    }
}
