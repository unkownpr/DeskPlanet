import SwiftUI
import AppKit

struct PopoverView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var plantState: PlantState
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showStats = false
    @State private var showSettings = false
    @State private var showOnboarding = false
    
    init(timer: PomodoroTimer, plantState: PlantState) {
        self.timer = timer
        self.plantState = plantState
        // İlk açılışta onboarding göster
        _showOnboarding = State(initialValue: !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with tabs
            HStack(spacing: 0) {
                TabButton(title: "tab.plant".localized, isSelected: !showStats && !showSettings) {
                    showStats = false
                    showSettings = false
                }

                TabButton(title: "tab.stats".localized, isSelected: showStats) {
                    showStats = true
                    showSettings = false
                }

                TabButton(title: "tab.settings".localized, isSelected: showSettings) {
                    showStats = false
                    showSettings = true
                }
            }
            .frame(height: 40)
            .id(localizationManager.currentLanguage)

            Divider()

            // Content
            Group {
                if showStats {
                    StatsView(timer: timer)
                } else if showSettings {
                    SettingsView(plantState: plantState, timer: timer)
                } else {
                    MainPlantView(timer: timer, plantState: plantState)
                }
            }
            .frame(width: 320, height: 450)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowOnboarding"))) { _ in
            showOnboarding = true
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Main Plant View
struct MainPlantView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var plantState: PlantState
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Plant animation
                PlantAnimationView(plantState: plantState)
                    .padding(.top, 20)

            // Plant info
            VStack(spacing: 8) {
                Text(plantState.type.name)
                    .font(.title2)
                    .bold()

                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("plant.health".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(plantState.healthStatus.localized)
                            .font(.subheadline)
                            .bold()
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(spacing: 4) {
                        Text("plant.level".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(plantState.level)")
                            .font(.subheadline)
                            .bold()
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(spacing: 4) {
                        Text("plant.sessions".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(plantState.totalSessions)")
                            .font(.subheadline)
                            .bold()
                    }
                }
                .id(localizationManager.currentLanguage)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)

            // Health bar
            VStack(spacing: 4) {
                HStack {
                    Text("plant.health".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(plantState.health))%")
                        .font(.caption)
                        .bold()
                }
                .id(localizationManager.currentLanguage)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(healthColor)
                            .frame(width: geometry.size.width * (plantState.health / 100.0), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal)

            // Timer display
            VStack(spacing: 8) {
                Text(timer.formattedTime)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(timerColor)

                if timer.state != .idle {
                    ProgressView(value: timer.progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: timerColor))
                        .frame(width: 200)
                }

                Text(stateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

                // Control buttons
                HStack(spacing: 12) {
                    if timer.state == .idle {
                        PrimaryButton(title: "button.startFocus".localized, icon: "play.fill") {
                            timer.startWork()
                        }
                    } else if timer.state == .paused {
                        SecondaryButton(title: "button.resume".localized, icon: "play.fill") {
                            timer.resume()
                        }
                        SecondaryButton(title: "button.stop".localized, icon: "stop.fill") {
                            timer.stop()
                        }
                    } else {
                        SecondaryButton(title: "button.pause".localized, icon: "pause.fill") {
                            timer.pause()
                        }
                        SecondaryButton(title: "button.skip".localized, icon: "forward.fill") {
                            timer.skip()
                        }
                    }
                }
                .id(localizationManager.currentLanguage)
                .padding(.bottom, 20)
            }
        }
    }

    private var timerColor: Color {
        switch timer.state {
        case .working:
            return .green
        case .break_:
            return .blue
        case .paused:
            return .orange
        case .idle:
            return .gray
        }
    }

    private var stateText: String {
        switch timer.state {
        case .idle:
            return "timer.readyToFocus".localized
        case .working:
            return "timer.focusTime".localized
        case .break_:
            return "timer.breakTime".localized
        case .paused:
            return "timer.paused".localized
        }
    }

    private var healthColor: Color {
        switch plantState.health {
        case 80...100:
            return .green
        case 60..<80:
            return .yellow
        case 40..<60:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Buttons
struct PrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var plantState: PlantState
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var licenseManager = LicenseManager.shared
    @State private var launchAtLogin: Bool = LaunchAtLogin.isEnabled
    @State private var selectedPlantType: PlantType
    @State private var showUpgradeAlert = false
    @State private var showLicense = false

    init(plantState: PlantState, timer: PomodoroTimer) {
        self.plantState = plantState
        self.timer = timer
        _selectedPlantType = State(initialValue: plantState.type)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Plant selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("settings.choosePlant".localized)
                        .font(.headline)

                    ForEach(licenseManager.getAvailablePlants()) { type in
                        PlantTypeCard(
                            type: type,
                            isSelected: selectedPlantType == type
                        ) {
                            selectedPlantType = type
                            plantState.type = type
                            DataManager.shared.save()
                        }
                    }
                    
                    // Show locked plants for free users
                    if !licenseManager.licenseInfo.isPro {
                        ForEach(PlantType.allCases.filter { !licenseManager.getAvailablePlants().contains($0) }) { type in
                            LockedPlantCard(type: type) {
                                showUpgradeAlert = true
                            }
                        }
                    }
                }
                .padding()

                Divider()

                // Timer settings
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("settings.timerSettings".localized)
                            .font(.headline)
                        
                        if !licenseManager.canChangeTimerSettings {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if licenseManager.canChangeTimerSettings {
                        TimerSettingRow(
                            title: "settings.workDuration".localized,
                            value: Int(timer.workDuration / 60),
                            range: 15...60,
                            unit: "unit.min".localized
                        ) { newValue in
                            timer.workDuration = TimeInterval(newValue * 60)
                        }

                        TimerSettingRow(
                            title: "settings.shortBreak".localized,
                            value: Int(timer.breakDuration / 60),
                            range: 3...15,
                            unit: "unit.min".localized
                        ) { newValue in
                            timer.breakDuration = TimeInterval(newValue * 60)
                        }

                        TimerSettingRow(
                            title: "settings.longBreak".localized,
                            value: Int(timer.longBreakDuration / 60),
                            range: 10...30,
                            unit: "unit.min".localized
                        ) { newValue in
                            timer.longBreakDuration = TimeInterval(newValue * 60)
                        }
                    } else {
                        // Show locked state
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text("license.restrictedFeature".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Text("license.upgradeMessage".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            
                            Button("license.activate".localized) {
                                showUpgradeAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .id(localizationManager.currentLanguage)

                Divider()
                
                // Language Selection
                VStack(alignment: .leading, spacing: 12) {
                    LanguageSelector()
                }
                .padding()
                
                Divider()
                
                // License Section
                LicenseSection()
                
                Divider()
                
                // Launch at Login
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $launchAtLogin) {
                        HStack {
                            Image(systemName: "power.circle")
                            Text("settings.launchAtLogin".localized)
                        }
                        .font(.subheadline)
                    }
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
                }
                .padding()
                
                Divider()
                
                // Tour button
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowOnboarding"), object: nil)
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("settings.howToUse".localized)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.top)

                Divider()
                    .padding(.top, 8)

                // License Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("license.section.title".localized)
                        .font(.headline)
                    
                    Button(action: { showLicense = true }) {
                        HStack {
                            Image(systemName: licenseManager.isLicensed ? "checkmark.seal.fill" : "key.fill")
                                .foregroundColor(licenseManager.isLicensed ? .green : .accentColor)
                            
                            if licenseManager.isLicensed {
                                Text("license.status.active".localized)
                                    .foregroundColor(.primary)
                            } else {
                                Text("license.button.activate".localized)
                                    .foregroundColor(.accentColor)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if !licenseManager.isLicensed {
                        Text("license.info.trial".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                Divider()
                    .padding(.top, 8)

                // About
                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.about".localized)
                        .font(.headline)

                    Text("settings.version".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("settings.description".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Creator
                    Link(destination: URL(string: "https://ssilistre.dev")!) {
                        HStack(spacing: 4) {
                            Text("Created by")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("ssilistre.dev")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                                .underline()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 4)
                }
                .padding()
                .id(localizationManager.currentLanguage)

                // Quit button
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("button.quit".localized)
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .alert("license.upgradeMessage".localized, isPresented: $showUpgradeAlert) {
            Button("license.cancel".localized, role: .cancel) { }
            Button("license.activate".localized) {
                showLicense = true
            }
        } message: {
            Text("license.restrictedFeature".localized)
        }
        .sheet(isPresented: $showLicense) {
            LicenseView()
        }
    }
    
    private func showLicenseActivation() {
        let activationView = LicenseActivationView()
        let hostingController = NSHostingController(rootView: activationView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "license.activate".localized
        window.styleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable]
        window.center()
        window.level = NSWindow.Level.floating
        window.makeKeyAndOrderFront(nil as Any?)
        
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Plant Type Card
struct PlantTypeCard: View {
    let type: PlantType
    let isSelected: Bool
    let action: () -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        Button(action: action) {
            HStack {
                Text(type.emoji)
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.nameKey.localized)
                        .font(.headline)
                    Text(type.descriptionKey.localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .id(localizationManager.currentLanguage) // Dil değişince güncelle
    }
}

// MARK: - Locked Plant Card
struct LockedPlantCard: View {
    let type: PlantType
    let action: () -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(type.emoji)
                    .font(.largeTitle)
                    .grayscale(0.8)
                    .opacity(0.5)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(type.nameKey.localized)
                            .font(.headline)
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    Text(type.descriptionKey.localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .id(localizationManager.currentLanguage)
    }
}

// MARK: - Timer Setting Row
struct TimerSettingRow: View {
    let title: String
    let value: Int
    let range: ClosedRange<Int>
    let unit: String
    let onChange: (Int) -> Void
    
    @State private var textValue: String = ""
    @State private var isEditing: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)

            Spacer()

            // Stepper buttons
            HStack(spacing: 8) {
                // Azalt butonu
                Button(action: {
                    let newValue = max(range.lowerBound, value - 1)
                    onChange(newValue)
                    textValue = "\(newValue)"
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(value > range.lowerBound ? .accentColor : .gray)
                        .font(.system(size: 20))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value <= range.lowerBound)
                
                // TextField ile direkt düzenleme
                TextField("\(value)", text: $textValue, onEditingChanged: { editing in
                    isEditing = editing
                    if !editing {
                        // Düzenleme bittiğinde değeri güncelle
                        if let newValue = Int(textValue), range.contains(newValue) {
                            onChange(newValue)
                        } else {
                            // Geçersiz değer, eski değere dön
                            textValue = "\(value)"
                        }
                    }
                }, onCommit: {
                    // Enter'a basıldığında
                    if let newValue = Int(textValue), range.contains(newValue) {
                        onChange(newValue)
                    } else {
                        textValue = "\(value)"
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .padding(6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isEditing ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onAppear {
                    textValue = "\(value)"
                }
                .onChange(of: value) { newValue in
                    if !isEditing {
                        textValue = "\(newValue)"
                    }
                }
                
                // Arttır butonu
                Button(action: {
                    let newValue = min(range.upperBound, value + 1)
                    onChange(newValue)
                    textValue = "\(newValue)"
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(value < range.upperBound ? .accentColor : .gray)
                        .font(.system(size: 20))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value >= range.upperBound)
                
                Text(unit)
                .font(.subheadline)
                .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .leading)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
    }
}

// MARK: - Language Selector
struct LanguageSelector: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        HStack {
            Text("settings.language".localized)
                .font(.subheadline)
            
            Spacer()
            
            Picker("", selection: $localizationManager.currentLanguage) {
                ForEach(Language.allCases) { language in
                    Text("\(language.flag) \(language.displayName)")
                        .tag(language)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 150)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}

// MARK: - License Section
struct LicenseSection: View {
    @ObservedObject private var licenseManager = LicenseManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showActivationWindow = false
    @State private var showInfoWindow = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("license.title".localized)
                .font(.headline)
            
            // License status card
            HStack(spacing: 12) {
                // Icon
                Image(systemName: licenseManager.licenseInfo.isPro ? "checkmark.seal.fill" : "lock.fill")
                    .font(.system(size: 30))
                    .foregroundColor(licenseManager.licenseInfo.isPro ? .green : .orange)
                    .frame(width: 40)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(licenseManager.licenseInfo.type.displayName)
                        .font(.system(size: 14, weight: .bold))
                    
                    Text(licenseManager.licenseInfo.status.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if !licenseManager.licenseInfo.isPro {
                        Text("license.upgradeMessage".localized)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Action button
                Button(action: {
                    if licenseManager.licenseInfo.isPro {
                        showLicenseInfo()
                    } else {
                        showLicenseActivation()
                    }
                }) {
                    Text(licenseManager.licenseInfo.isPro ? "license.title".localized : "license.activate".localized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(licenseManager.licenseInfo.isPro ? Color.blue : Color.accentColor)
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
        }
        .padding()
        .id(localizationManager.currentLanguage)
    }
    
    private func showLicenseActivation() {
        let activationView = LicenseActivationView()
        let hostingController = NSHostingController(rootView: activationView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "license.activate".localized
        window.styleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable]
        window.center()
        window.level = NSWindow.Level.floating
        window.makeKeyAndOrderFront(nil as Any?)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func showLicenseInfo() {
        let infoView = LicenseInfoView()
        let hostingController = NSHostingController(rootView: infoView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "license.title".localized
        window.styleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable]
        window.center()
        window.level = NSWindow.Level.floating
        window.makeKeyAndOrderFront(nil as Any?)
        
        NSApp.activate(ignoringOtherApps: true)
    }
}
