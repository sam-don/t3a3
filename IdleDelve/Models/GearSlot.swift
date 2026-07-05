import Foundation

enum GearSlot: String, Codable, CaseIterable, Identifiable, Hashable {
    case weapon
    case armor
    case trinket

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weapon: return "Weapon"
        case .armor: return "Armor"
        case .trinket: return "Trinket"
        }
    }

    var icon: String {
        switch self {
        case .weapon: return "bolt.fill"
        case .armor: return "shield.fill"
        case .trinket: return "sparkles"
        }
    }

    /// The stat this slot is guaranteed to roll on every drop.
    var primaryStat: StatType {
        switch self {
        case .weapon: return .attack
        case .armor: return .defense
        case .trinket: return .critChance
        }
    }
}
