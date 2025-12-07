import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var plantState: PlantState

    private let plantStateKey = "plantState"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        // Load saved plant state or create new one
        if let data = UserDefaults.standard.data(forKey: plantStateKey),
           let savedState = try? decoder.decode(PlantState.self, from: data) {
            plantState = savedState
            print("Loaded plant state: \(savedState.type.name), Health: \(savedState.health)")
        } else {
            plantState = PlantState()
            print("Created new plant state")
        }

        // Check plant health on load
        plantState.checkHealth()

        // Set up auto-save timer (every 5 minutes)
        setupAutoSave()
    }

    // MARK: - Persistence
    func save() {
        if let encoded = try? encoder.encode(plantState) {
            UserDefaults.standard.set(encoded, forKey: plantStateKey)
            print("Plant state saved: Health \(plantState.health), Level \(plantState.level)")
        }
    }

    func reset() {
        plantState = PlantState()
        save()
        PomodoroTimer.shared.sessionsCompleted = 0
        print("Plant state reset")
    }

    // MARK: - Auto-save
    private func setupAutoSave() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.save()
            self?.plantState.checkHealth()
        }
    }

    // MARK: - Export/Import (for future iCloud sync)
    func exportData() -> Data? {
        let exportData = ExportData(
            plantState: plantState,
            dailyStats: PomodoroTimer.shared.dailyStats,
            exportDate: Date()
        )

        return try? encoder.encode(exportData)
    }

    func importData(_ data: Data) -> Bool {
        guard let importData = try? decoder.decode(ExportData.self, from: data) else {
            return false
        }

        plantState = importData.plantState
        PomodoroTimer.shared.dailyStats = importData.dailyStats
        save()

        return true
    }

    // MARK: - Statistics
    func getTotalFocusTime() -> TimeInterval {
        return TimeInterval(PomodoroTimer.shared.dailyStats.reduce(0) { $0 + $1.totalMinutes } * 60)
    }

    func getTotalSessions() -> Int {
        return plantState.totalSessions
    }

    func getStreak() -> Int {
        let calendar = Calendar.current
        let sortedStats = PomodoroTimer.shared.dailyStats.sorted(by: { $0.date > $1.date })

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for stat in sortedStats {
            if calendar.isDate(stat.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streak
    }
}

// MARK: - Export/Import Data Structure
struct ExportData: Codable {
    let plantState: PlantState
    let dailyStats: [DailyStat]
    let exportDate: Date
}
