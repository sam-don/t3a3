import Foundation

/// Every stat a hero can have, contributed to by base level, gear, talents,
/// and permanent ascension upgrades.
enum StatType: String, Codable, CaseIterable, Identifiable, Hashable {
    case attack
    case defense
    case maxHP
    case critChance
    case critDamage
    case goldFind
    case xpGain

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .attack: return "Attack"
        case .defense: return "Defense"
        case .maxHP: return "Max HP"
        case .critChance: return "Crit Chance"
        case .critDamage: return "Crit Damage"
        case .goldFind: return "Gold Find"
        case .xpGain: return "XP Gain"
        }
    }

    var icon: String {
        switch self {
        case .attack: return "bolt.fill"
        case .defense: return "shield.fill"
        case .maxHP: return "heart.fill"
        case .critChance: return "target"
        case .critDamage: return "flame.fill"
        case .goldFind: return "dollarsign.circle.fill"
        case .xpGain: return "star.fill"
        }
    }

    /// Crit chance/damage are already expressed as fractions, so talent and
    /// ascension bonuses add directly onto them. Every other stat treats
    /// talent/ascension bonuses as a multiplicative percentage on top of the
    /// flat (base + gear) total, since flat additions alone become
    /// meaningless once gear numbers get large.
    var talentBonusIsMultiplicative: Bool {
        switch self {
        case .attack, .defense, .maxHP, .goldFind, .xpGain:
            return true
        case .critChance, .critDamage:
            return false
        }
    }

    /// Whether this stat's raw Double is a fraction meant to be displayed as
    /// a percentage (e.g. 0.05 -> "5%") versus a flat number.
    var isPercentLike: Bool {
        switch self {
        case .critChance, .critDamage, .goldFind, .xpGain:
            return true
        case .attack, .defense, .maxHP:
            return false
        }
    }
}
