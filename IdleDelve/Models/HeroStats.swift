import Foundation

/// Fully resolved hero stats for the current tick: base + level scaling,
/// gear affixes, talent ranks, and ascension ranks all folded together.
struct HeroStats: Equatable {
    var attack: Double
    var defense: Double
    var maxHP: Double
    var critChance: Double
    var critDamage: Double
    var goldFind: Double
    var xpGain: Double

    static let zero = HeroStats(attack: 0, defense: 0, maxHP: 0, critChance: 0, critDamage: 0, goldFind: 0, xpGain: 0)

    static func compute(state: GameState) -> HeroStats {
        let level = state.hero.level

        var flat: [StatType: Double] = [
            .attack: Hero.baseAttack + Double(level - 1) * 1.4,
            .defense: Hero.baseDefense + Double(level - 1) * 0.7,
            .maxHP: Hero.baseMaxHP + Double(level - 1) * 9,
            .critChance: Hero.baseCritChance,
            .critDamage: Hero.baseCritDamage,
            .goldFind: 0,
            .xpGain: 0
        ]

        for item in state.equippedGear.values {
            for affix in item.affixes {
                flat[affix.stat, default: 0] += affix.value
            }
        }

        var multiplicativeBonus: [StatType: Double] = [:]
        var additiveBonus: [StatType: Double] = [:]

        for stat in StatType.allCases {
            let combined = TalentTree.totalBonus(for: stat, ranks: state.talentRanks)
                + AscensionTree.totalBonus(for: stat, ranks: state.ascensionRanks)
            if stat.talentBonusIsMultiplicative {
                multiplicativeBonus[stat, default: 0] += combined
            } else {
                additiveBonus[stat, default: 0] += combined
            }
        }

        var result: [StatType: Double] = [:]
        for stat in StatType.allCases {
            let base = flat[stat] ?? 0
            let multiplier = 1 + (multiplicativeBonus[stat] ?? 0)
            let addition = additiveBonus[stat] ?? 0
            result[stat] = base * multiplier + addition
        }

        return HeroStats(
            attack: result[.attack] ?? 0,
            defense: result[.defense] ?? 0,
            maxHP: result[.maxHP] ?? 0,
            critChance: min(1.0, result[.critChance] ?? 0),
            critDamage: result[.critDamage] ?? 0,
            goldFind: result[.goldFind] ?? 0,
            xpGain: result[.xpGain] ?? 0
        )
    }
}
