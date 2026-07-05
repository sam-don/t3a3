import Foundation

enum Rarity: Int, Codable, CaseIterable, Comparable, Equatable, Identifiable {
    case common = 0
    case uncommon
    case rare
    case epic
    case legendary
    case mythic

    var id: Int { rawValue }

    static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        case .mythic: return "Mythic"
        }
    }

    /// Multiplier applied to a gear item's rolled affix values.
    var statMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.3
        case .rare: return 1.7
        case .epic: return 2.3
        case .legendary: return 3.2
        case .mythic: return 4.5
        }
    }

    /// Relative drop weight used by the loot table.
    var dropWeight: Double {
        switch self {
        case .common: return 100
        case .uncommon: return 45
        case .rare: return 18
        case .epic: return 6
        case .legendary: return 1.5
        case .mythic: return 0.25
        }
    }
}
