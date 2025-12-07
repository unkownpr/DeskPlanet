import SwiftUI
import AppKit

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var timer: Timer?

    private let pomodoroTimer = PomodoroTimer.shared
    private let dataManager = DataManager.shared
    private let licenseManager = LicenseManager.shared
    
    // License windows
    private var licenseActivationWindow: NSWindow?
    private var licenseInfoWindow: NSWindow?

    init() {
        setupStatusItem()
        setupPopover()
        startUpdatingIcon()
        observeNotifications()
        
        // Otomatik olarak popover'ı göster (first launch veya her zaman)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showPopover()
        }
    }

    // MARK: - Setup
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            updateButtonIcon()
            button.action = #selector(handleClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 490)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: PopoverView(
                timer: pomodoroTimer,
                plantState: dataManager.plantState
            )
        )
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPopover),
            name: NSNotification.Name("ShowApp"),
            object: nil
        )
        
        // Dil değiştiğinde menüyü güncelle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    @objc private func languageChanged() {
        updateContextMenu()
        updateButtonIcon()
    }

    // MARK: - Popover Control
    @objc private func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Sağ tık - context menü göster
            showContextMenu()
        } else {
            // Sol tık - popover aç/kapat
            togglePopover()
        }
    }
    
    private func showContextMenu() {
        guard let button = statusItem?.button else { return }
        let menu = createContextMenu()
        
        // Menüyü manuel olarak göster
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
    }
    
    @objc private func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                closePopover()
            } else {
                showPopover()
            }
        }
    }

    @objc private func showPopover() {
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Bring app to front
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func closePopover() {
        popover?.performClose(nil)
    }

    // MARK: - Icon Updates
    private func startUpdatingIcon() {
        // Update icon every second when timer is running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateButtonIcon()
            self?.updateContextMenu()
        }
    }
    
    private func updateContextMenu() {
        // Context menü dinamik olarak oluşturuluyor, burada bir şey yapmaya gerek yok
    }

    private func updateButtonIcon() {
        guard let button = statusItem?.button else { return }

        let plant = dataManager.plantState
        let timer = pomodoroTimer

        // Create icon based on plant and timer state
        let icon = createStatusIcon(plant: plant, timerState: timer.state)

        button.image = icon
        button.imagePosition = .imageLeading

        // Add timer text next to icon when active
        if timer.state != .idle {
            button.title = " \(timer.formattedTime)"
        } else {
            button.title = ""
        }

        // Add tooltip
        button.toolTip = createTooltip(plant: plant, timer: timer)
    }

    private func createStatusIcon(plant: PlantState, timerState: TimerState) -> NSImage? {
        // Use SF Symbols for the icon
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)

        let imageName: String
        switch timerState {
        case .working:
            imageName = "leaf.fill"
        case .break_:
            imageName = "cup.and.saucer.fill"
        case .paused:
            imageName = "pause.circle.fill"
        case .idle:
            imageName = plant.type.emoji == "🌳" ? "leaf" :
                       plant.type.emoji == "🌵" ? "camera.macro" : "leaf"
        }

        let image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        image?.isTemplate = true

        return image?.withSymbolConfiguration(config)
    }

    private func createTooltip(plant: PlantState, timer: PomodoroTimer) -> String {
        var tooltip = "DeskPlant - \(plant.type.name)\n"
        tooltip += "\("plant.health".localized): \(Int(plant.health))% (\(plant.healthStatus.localized))\n"
        tooltip += "\("plant.level".localized): \(plant.level) | \("plant.sessions".localized): \(plant.totalSessions)\n"

        switch timer.state {
        case .working:
            tooltip += "\n\("timer.focus".localized): \(timer.formattedTime) \("timer.remaining".localized)"
        case .break_:
            tooltip += "\n\("timer.break".localized): \(timer.formattedTime) \("timer.remaining".localized)"
        case .paused:
            tooltip += "\n\("timer.paused".localized)"
        case .idle:
            tooltip += "\n\("timer.clickToStart".localized)"
        }

        return tooltip
    }

    // MARK: - Context Menu
    private func createContextMenu() -> NSMenu {
        let menu = NSMenu()

        // Timer kontrol
        if pomodoroTimer.state == .idle {
            let item = NSMenuItem(
                title: "button.startFocus".localized,
                action: #selector(quickStartFocus),
                keyEquivalent: "f"
            )
            item.target = self
            menu.addItem(item)
        } else if pomodoroTimer.state == .paused {
            let resumeItem = NSMenuItem(
                title: "button.resume".localized,
                action: #selector(quickResume),
                keyEquivalent: "r"
            )
            resumeItem.target = self
            menu.addItem(resumeItem)
            
            let stopItem = NSMenuItem(
                title: "button.stop".localized,
                action: #selector(quickStop),
                keyEquivalent: "s"
            )
            stopItem.target = self
            menu.addItem(stopItem)
        } else {
            let pauseItem = NSMenuItem(
                title: "button.pause".localized,
                action: #selector(quickPause),
                keyEquivalent: "p"
            )
            pauseItem.target = self
            menu.addItem(pauseItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Plant info
        let plantInfo = NSMenuItem(
            title: "\(dataManager.plantState.type.emoji) \(dataManager.plantState.healthStatus.localized) - \("plant.level".localized) \(dataManager.plantState.level)",
            action: nil,
            keyEquivalent: ""
        )
        plantInfo.isEnabled = false
        menu.addItem(plantInfo)

        menu.addItem(NSMenuItem.separator())

        // Open
        let openItem = NSMenuItem(
            title: "menu.open".localized,
            action: #selector(showPopover),
            keyEquivalent: "o"
        )
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(NSMenuItem.separator())
        
        // License menu
        if licenseManager.licenseInfo.isPro {
            let licenseInfoItem = NSMenuItem(
                title: "menu.licenseInfo".localized,
                action: #selector(showLicenseInfo),
                keyEquivalent: ""
            )
            licenseInfoItem.target = self
            menu.addItem(licenseInfoItem)
        } else {
            let activateLicenseItem = NSMenuItem(
                title: "menu.activateLicense".localized,
                action: #selector(showLicenseActivation),
                keyEquivalent: ""
            )
            activateLicenseItem.target = self
            menu.addItem(activateLicenseItem)
        }
        
        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "button.quit".localized,
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func quickStartFocus() {
        pomodoroTimer.startWork()
        closePopover()
        updateButtonIcon()
        updateContextMenu()
    }
    
    @objc private func quickPause() {
        pomodoroTimer.pause()
        updateButtonIcon()
        updateContextMenu()
    }
    
    @objc private func quickResume() {
        pomodoroTimer.resume()
        updateButtonIcon()
        updateContextMenu()
    }
    
    @objc private func quickStop() {
        pomodoroTimer.stop()
        updateButtonIcon()
        updateContextMenu()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - License Actions
    @objc private func showLicenseActivation() {
        // Close any existing license windows
        licenseActivationWindow?.close()
        licenseInfoWindow?.close()
        
        let activationView = LicenseActivationView()
        let hostingController = NSHostingController(rootView: activationView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "license.activate".localized
        window.styleMask = [.titled, .closable]
        window.center()
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        
        licenseActivationWindow = window
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showLicenseInfo() {
        // Close any existing license windows
        licenseActivationWindow?.close()
        licenseInfoWindow?.close()
        
        let infoView = LicenseInfoView()
        let hostingController = NSHostingController(rootView: infoView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "license.title".localized
        window.styleMask = [.titled, .closable]
        window.center()
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        
        licenseInfoWindow = window
        
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Cleanup
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
