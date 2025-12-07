import Foundation
import Combine

enum TimerState {
    case idle
    case working
    case break_
    case paused
}

class PomodoroTimer: ObservableObject {
    @Published var state: TimerState = .idle
    @Published var timeRemaining: TimeInterval = 0
    @Published var workDuration: TimeInterval = 25 * 60 // 25 minutes
    @Published var breakDuration: TimeInterval = 5 * 60 // 5 minutes
    @Published var longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    @Published var sessionsCompleted: Int = 0
    @Published var dailyStats: [DailyStat] = []

    private var timer: Timer?
    private var startTime: Date?

    static let shared = PomodoroTimer()

    private init() {
        loadDailyStats()
    }

    // MARK: - Timer Control
    func startWork() {
        state = .working
        timeRemaining = workDuration
        startTime = Date()
        startTimer()
    }

    func startBreak() {
        state = .break_
        // Long break every 4 sessions
        timeRemaining = (sessionsCompleted % 4 == 0 && sessionsCompleted > 0) ? longBreakDuration : breakDuration
        startTime = Date()
        startTimer()
    }

    func pause() {
        guard state == .working || state == .break_ else { return }
        state = .paused
        stopTimer()
    }

    func resume() {
        guard state == .paused else { return }
        state = timeRemaining > 0 ? (sessionsCompleted % 2 == 0 ? .working : .break_) : .idle
        startTimer()
    }

    func stop() {
        state = .idle
        timeRemaining = 0
        stopTimer()
    }

    func skip() {
        if state == .working {
            completeWorkSession(isSkipped: true)
        } else if state == .break_ {
            completeBreak()
        }
    }

    // MARK: - Private Methods
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard timeRemaining > 0 else {
            if state == .working {
                completeWorkSession(isSkipped: false)
            } else if state == .break_ {
                completeBreak()
            }
            return
        }

        timeRemaining -= 1
    }

    private func completeWorkSession(isSkipped: Bool = false) {
        stopTimer()
        
        // Sadece tam süre tamamlandıysa ödül ver
        if !isSkipped {
            sessionsCompleted += 1
            recordSession()
            // Water the plant - Sadece tam seans tamamlandığında!
            DataManager.shared.plantState.water()
        }
        
        let message = isSkipped ? 
            "Session skipped. Complete full sessions to water your plant!" :
            "Great job! Time for a \(sessionsCompleted % 4 == 0 ? "long" : "short") break."
        
        NotificationManager.shared.sendNotification(
            title: isSkipped ? "Session Skipped" : "Work Session Complete!",
            body: message,
            sound: true
        )

        state = .idle
    }

    private func completeBreak() {
        stopTimer()
        NotificationManager.shared.sendNotification(
            title: "Break Complete!",
            body: "Ready to focus again?",
            sound: true
        )
        state = .idle
    }

    private func recordSession() {
        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyStats[index].sessionsCompleted += 1
            dailyStats[index].totalMinutes += Int(workDuration / 60)
        } else {
            let newStat = DailyStat(
                date: today,
                sessionsCompleted: 1,
                totalMinutes: Int(workDuration / 60)
            )
            dailyStats.append(newStat)
        }

        saveDailyStats()
    }

    // MARK: - Statistics
    func todayStats() -> DailyStat? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyStats.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
    }

    func weekStats() -> [DailyStat] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        return dailyStats.filter { $0.date >= weekAgo }.sorted(by: { $0.date > $1.date })
    }

    // MARK: - Persistence
    private func saveDailyStats() {
        if let encoded = try? JSONEncoder().encode(dailyStats) {
            UserDefaults.standard.set(encoded, forKey: "dailyStats")
        }
    }

    private func loadDailyStats() {
        if let data = UserDefaults.standard.data(forKey: "dailyStats"),
           let decoded = try? JSONDecoder().decode([DailyStat].self, from: data) {
            dailyStats = decoded
        }
    }

    // MARK: - Formatted Time
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progressPercentage: Double {
        let totalDuration = state == .working ? workDuration : (sessionsCompleted % 4 == 0 ? longBreakDuration : breakDuration)
        return (totalDuration - timeRemaining) / totalDuration
    }
}

// MARK: - Daily Statistics
struct DailyStat: Codable, Identifiable {
    var id: Date { date }
    let date: Date
    var sessionsCompleted: Int
    var totalMinutes: Int

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
