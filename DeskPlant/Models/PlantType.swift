import SwiftUI

enum PlantType: String, CaseIterable, Codable, Identifiable {
    case bonsai = "Bonsai"
    case cactus = "Cactus"
    case bamboo = "Bamboo"
    case sunflower = "Sunflower"
    case sakura = "Sakura"
    case monstera = "Monstera"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .bonsai:
            return "🌳"
        case .cactus:
            return "🌵"
        case .bamboo:
            return "🎋"
        case .sunflower:
            return "🌻"
        case .sakura:
            return "🌸"
        case .monstera:
            return "🌿"
        }
    }
    
    /// Emoji when plant is wilting (health < 40)
    var wiltingEmoji: String {
        switch self {
        case .bonsai:
            return "🍂"
        case .cactus:
            return "🏜️"
        case .bamboo:
            return "🍃"
        case .sunflower:
            return "🥀"
        case .sakura:
            return "🍂"
        case .monstera:
            return "🍃"
        }
    }
    
    /// Emoji when plant is critical (health < 20)
    var criticalEmoji: String {
        switch self {
        case .bonsai, .sakura, .sunflower:
            return "🥀"
        case .cactus:
            return "💀"
        case .bamboo, .monstera:
            return "🪵"
        }
    }

    var nameKey: String {
        switch self {
        case .bonsai: return "plant.type.bonsai"
        case .cactus: return "plant.type.cactus"
        case .bamboo: return "plant.type.bamboo"
        case .sunflower: return "plant.type.sunflower"
        case .sakura: return "plant.type.sakura"
        case .monstera: return "plant.type.monstera"
        }
    }
    
    var descriptionKey: String {
        switch self {
        case .bonsai: return "plant.description.bonsai"
        case .cactus: return "plant.description.cactus"
        case .bamboo: return "plant.description.bamboo"
        case .sunflower: return "plant.description.sunflower"
        case .sakura: return "plant.description.sakura"
        case .monstera: return "plant.description.monstera"
        }
    }
    
    var name: String {
        return nameKey.localized
    }
    
    var description: String {
        return descriptionKey.localized
    }

    var growthRate: Double {
        switch self {
        case .bonsai:
            return 0.8  // Slower growth
        case .cactus:
            return 1.0  // Normal growth
        case .bamboo:
            return 1.3  // Faster growth
        case .sunflower:
            return 1.2  // Quick growth
        case .sakura:
            return 0.9  // Delicate growth
        case .monstera:
            return 1.1  // Steady growth
        }
    }

    var withersRate: Double {
        switch self {
        case .bonsai:
            return 1.2  // Withers faster when neglected
        case .cactus:
            return 0.7  // More forgiving
        case .bamboo:
            return 1.0  // Normal withering
        case .sunflower:
            return 1.3  // Needs constant care
        case .sakura:
            return 1.4  // Very delicate
        case .monstera:
            return 0.9  // Quite resilient
        }
    }

    var color: Color {
        switch self {
        case .bonsai:
            return .green
        case .cactus:
            return Color(red: 0.2, green: 0.6, blue: 0.4)
        case .bamboo:
            return Color(red: 0.4, green: 0.7, blue: 0.3)
        case .sunflower:
            return Color(red: 0.9, green: 0.7, blue: 0.2)
        case .sakura:
            return Color(red: 1.0, green: 0.7, blue: 0.8)
        case .monstera:
            return Color(red: 0.1, green: 0.5, blue: 0.3)
        }
    }
}
