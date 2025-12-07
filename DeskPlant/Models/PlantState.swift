import Foundation

class PlantState: ObservableObject, Codable {
    @Published var type: PlantType
    @Published var health: Double // 0.0 to 100.0
    @Published var level: Int
    @Published var totalSessions: Int
    @Published var lastWatered: Date

    private enum CodingKeys: String, CodingKey {
        case type, health, level, totalSessions, lastWatered
    }

    init(type: PlantType = .bonsai) {
        self.type = type
        self.health = 100.0
        self.level = 1
        self.totalSessions = 0
        self.lastWatered = Date()
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(PlantType.self, forKey: .type)
        health = try container.decode(Double.self, forKey: .health)
        level = try container.decode(Int.self, forKey: .level)
        totalSessions = try container.decode(Int.self, forKey: .totalSessions)
        lastWatered = try container.decode(Date.self, forKey: .lastWatered)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(health, forKey: .health)
        try container.encode(level, forKey: .level)
        try container.encode(totalSessions, forKey: .totalSessions)
        try container.encode(lastWatered, forKey: .lastWatered)
    }

    // MARK: - Plant Care
    func water() {
        health = min(100.0, health + (10.0 * type.growthRate))
        totalSessions += 1
        lastWatered = Date()

        // Level up every 5 sessions
        if totalSessions % 5 == 0 {
            level += 1
        }

        DataManager.shared.save()
    }

    func wither() {
        health = max(0.0, health - (15.0 * type.withersRate))
        DataManager.shared.save()
    }

    func checkHealth() {
        let hoursSinceLastWater = Date().timeIntervalSince(lastWatered) / 3600

        // If more than 4 hours since last session, start withering
        if hoursSinceLastWater > 4 {
            let withersAmount = (hoursSinceLastWater - 4) * 2 * type.withersRate
            health = max(0.0, health - withersAmount)
            DataManager.shared.save()
        }
    }

    var healthStatus: String {
        switch health {
        case 80...100:
            return "plant.status.thriving"
        case 60..<80:
            return "plant.status.healthy"
        case 40..<60:
            return "plant.status.needscare"
        case 20..<40:
            return "plant.status.wilting"
        default:
            return "plant.status.critical"
        }
    }

    var size: Double {
        // Scale from 0.5 to 2.0 based on health and level
        let healthFactor = health / 100.0
        let levelFactor = min(Double(level) / 10.0, 1.0)
        return 0.5 + (healthFactor * levelFactor * 1.5)
    }
}
