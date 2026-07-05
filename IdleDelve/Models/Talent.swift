import Foundation

/// A single purchasable upgrade node. Used both by the per-run talent tree
/// (spent with skill points, reset on prestige) and the permanent ascension
/// tree (spent with essence, survives prestige) — same shape, different
/// currency and lifetime, so one type covers both.
struct Talent: Identifiable, Equatable {
    let id: String
    let name: String
    let stat: StatType
    let valuePerRank: Double
    let maxRank: Int
    let baseCost: Double
    let costGrowth: Double

    /// Cost to purchase the rank after `currentRank`.
    func cost(atRank currentRank: Int) -> Double {
        baseCost * pow(costGrowth, Double(currentRank))
    }
}

enum TalentTree {
    static let talents: [Talent] = [
        Talent(id: "warriors_strength", name: "Warrior's Strength", stat: .attack, valuePerRank: 0.03, maxRank: 50, baseCost: 1, costGrowth: 1.14),
        Talent(id: "iron_skin", name: "Iron Skin", stat: .defense, valuePerRank: 0.03, maxRank: 50, baseCost: 1, costGrowth: 1.14),
        Talent(id: "vitality", name: "Vitality", stat: .maxHP, valuePerRank: 0.04, maxRank: 50, baseCost: 1, costGrowth: 1.13),
        Talent(id: "keen_eye", name: "Keen Eye", stat: .critChance, valuePerRank: 0.005, maxRank: 30, baseCost: 2, costGrowth: 1.2),
        Talent(id: "ruthless", name: "Ruthless", stat: .critDamage, valuePerRank: 0.02, maxRank: 30, baseCost: 2, costGrowth: 1.2),
        Talent(id: "prospector", name: "Prospector", stat: .goldFind, valuePerRank: 0.02, maxRank: 40, baseCost: 1, costGrowth: 1.16),
        Talent(id: "scholar", name: "Scholar", stat: .xpGain, valuePerRank: 0.02, maxRank: 40, baseCost: 1, costGrowth: 1.16)
    ]

    static func talent(id: String) -> Talent? {
        talents.first { $0.id == id }
    }

    static func totalBonus(for stat: StatType, ranks: [String: Int]) -> Double {
        talents.filter { $0.stat == stat }.reduce(0) { partial, talent in
            partial + Double(ranks[talent.id] ?? 0) * talent.valuePerRank
        }
    }
}

/// Permanent upgrades bought with Essence (earned from prestiging). Unlike
/// talents, ascension ranks are never reset — they're the long-term
/// meta-progression layer that makes each prestige run faster than the last.
enum AscensionTree {
    static let upgrades: [Talent] = [
        Talent(id: "ascendant_power", name: "Ascendant Power", stat: .attack, valuePerRank: 0.05, maxRank: 100, baseCost: 1, costGrowth: 1.1),
        Talent(id: "ascendant_fortitude", name: "Ascendant Fortitude", stat: .maxHP, valuePerRank: 0.05, maxRank: 100, baseCost: 1, costGrowth: 1.1),
        Talent(id: "ascendant_greed", name: "Ascendant Greed", stat: .goldFind, valuePerRank: 0.04, maxRank: 100, baseCost: 1, costGrowth: 1.1),
        Talent(id: "ascendant_wisdom", name: "Ascendant Wisdom", stat: .xpGain, valuePerRank: 0.04, maxRank: 100, baseCost: 1, costGrowth: 1.1)
    ]

    static func upgrade(id: String) -> Talent? {
        upgrades.first { $0.id == id }
    }

    static func totalBonus(for stat: StatType, ranks: [String: Int]) -> Double {
        upgrades.filter { $0.stat == stat }.reduce(0) { partial, upgrade in
            partial + Double(ranks[upgrade.id] ?? 0) * upgrade.valuePerRank
        }
    }
}
