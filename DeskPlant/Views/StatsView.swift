import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Today's stats
                VStack(alignment: .leading, spacing: 12) {
                    Text("stats.today".localized)
                        .font(.title2)
                        .bold()

                    if let todayStats = timer.todayStats() {
                        TodayStatsCard(stats: todayStats)
                    } else {
                        EmptyStatsCard(message: "stats.emptyMessage".localized)
                    }
                }
                .padding()

                Divider()

                // Weekly chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("stats.thisWeek".localized)
                        .font(.title2)
                        .bold()

                    let weekStats = timer.weekStats()

                    if weekStats.isEmpty {
                        EmptyStatsCard(message: "stats.emptyMessage".localized)
                    } else {
                        WeeklyChart(stats: weekStats)

                        // Weekly summary
                        HStack(spacing: 20) {
                            StatBadge(
                                title: "stats.totalSessions".localized,
                                value: "\(weekStats.reduce(0) { $0 + $1.sessionsCompleted })",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )

                            StatBadge(
                                title: "stats.totalTime".localized,
                                value: "\(weekStats.reduce(0) { $0 + $1.totalMinutes }) \("unit.min".localized)",
                                icon: "clock.fill",
                                color: .blue
                            )
                        }
                    }
                }
                .padding()

                Divider()

                // Achievements/Milestones
                VStack(alignment: .leading, spacing: 12) {
                    Text("stats.achievements".localized)
                        .font(.title2)
                        .bold()

                    AchievementsGrid(totalSessions: timer.sessionsCompleted)
                }
                .padding()
            }
        }
    }
}

// MARK: - Today Stats Card
struct TodayStatsCard: View {
    let stats: DailyStat

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30) {
                StatCircle(
                    value: "\(stats.sessionsCompleted)",
                    title: "stats.sessions".localized,
                    color: .green
                )

                StatCircle(
                    value: "\(stats.totalMinutes)",
                    title: "stats.minutes".localized,
                    color: .blue
                )

                StatCircle(
                    value: "\(stats.totalMinutes / 60)h \(stats.totalMinutes % 60)m",
                    title: "stats.focusTime".localized,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Stat Circle
struct StatCircle: View {
    let value: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Empty Stats Card
struct EmptyStatsCard: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Weekly Chart
struct WeeklyChart: View {
    let stats: [DailyStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Chart
            Chart {
                ForEach(stats) { stat in
                    BarMark(
                        x: .value("Day", stat.formattedDate),
                        y: .value("Sessions", stat.sessionsCompleted)
                    )
                    .foregroundStyle(stat.isToday ? Color.accentColor : Color.green.opacity(0.7))
                    .cornerRadius(4)
                }
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding(.vertical, 8)

            // Legend
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                Text("stats.today".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer().frame(width: 12)

                Circle()
                    .fill(Color.green.opacity(0.7))
                    .frame(width: 8, height: 8)
                Text("stats.pastDays".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Achievements Grid
struct AchievementsGrid: View {
    let totalSessions: Int

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            AchievementCard(
                title: "achievement.firstSteps".localized,
                description: "achievement.firstSteps.desc".localized,
                icon: "figure.walk",
                isUnlocked: totalSessions >= 1,
                progress: min(totalSessions, 1)
            )

            AchievementCard(
                title: "achievement.gettingStarted".localized,
                description: "achievement.gettingStarted.desc".localized,
                icon: "star.fill",
                isUnlocked: totalSessions >= 5,
                progress: min(totalSessions, 5)
            )

            AchievementCard(
                title: "achievement.consistent".localized,
                description: "achievement.consistent.desc".localized,
                icon: "flame.fill",
                isUnlocked: totalSessions >= 25,
                progress: min(totalSessions, 25)
            )

            AchievementCard(
                title: "achievement.dedicated".localized,
                description: "achievement.dedicated.desc".localized,
                icon: "trophy.fill",
                isUnlocked: totalSessions >= 100,
                progress: min(totalSessions, 100)
            )
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let progress: Int

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(isUnlocked ? .yellow : .gray)

            Text(title)
                .font(.subheadline)
                .bold()

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            isUnlocked ?
                Color.yellow.opacity(0.1) :
                Color(NSColor.controlBackgroundColor)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? Color.yellow : Color.clear, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - Preview
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(timer: PomodoroTimer.shared)
            .frame(width: 320, height: 450)
    }
}
