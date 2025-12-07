import Foundation
import ServiceManagement

/// Utility class to manage Launch at Login functionality
class LaunchAtLogin {
    static var isEnabled: Bool {
        get {
            // Check if app is in login items
            return SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    // Enable launch at login
                    if SMAppService.mainApp.status == .enabled {
                        // Already enabled
                        return
                    }
                    try SMAppService.mainApp.register()
                } else {
                    // Disable launch at login
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
            }
        }
    }
}

