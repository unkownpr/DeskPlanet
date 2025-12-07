import SwiftUI
import UserNotifications

@main
struct DeskPlantApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    var notificationManager: NotificationManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        notificationManager = NotificationManager()
        notificationManager?.requestAuthorization()
        
        // Check license on startup
        Task {
            await LicenseManager.shared.checkLicenseOnStartup()
        }

        // Set up menu bar
        menuBarController = MenuBarController()

        // Hide dock icon (menu bar app only)
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Save any pending data
        DataManager.shared.save()
    }
}
