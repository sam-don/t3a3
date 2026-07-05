import Foundation

enum LootTable {
    static func rollDrop(forFloor floor: Int, isBoss: Bool) -> GearItem? {
        let dropChance = isBoss ? 0.9 : 0.12
        guard Double.random(in: 0...1) < dropChance else { return nil }
        let slot = GearSlot.allCases.randomElement() ?? .weapon
        let rarity = rollRarity(bossBonus: isBoss)
        let affixes = generateAffixes(slot: slot, rarity: rarity, itemLevel: floor)
        return GearItem(slot: slot, rarity: rarity, itemLevel: floor, affixes: affixes)
    }

    static func rollRarity(bossBonus: Bool) -> Rarity {
        let cases = Rarity.allCases
        let weights = cases.map { rarity -> Double in
            guard bossBonus else { return rarity.dropWeight }
            return rarity == .common ? rarity.dropWeight * 0.3 : rarity.dropWeight * 2.0
        }
        let total = weights.reduce(0, +)
        var roll = Double.random(in: 0..<total)
        for (index, weight) in weights.enumerated() {
            if roll < weight { return cases[index] }
            roll -= weight
        }
        return .common
    }

    static func generateAffixes(slot: GearSlot, rarity: Rarity, itemLevel: Int) -> [GearAffix] {
        let affixCount = min(3, 1 + rarity.rawValue / 2)
        var pool = StatType.allCases
        pool.removeAll { $0 == slot.primaryStat }

        var affixes = [rolledAffix(for: slot.primaryStat, slot: slot, rarity: rarity, itemLevel: itemLevel)]
        for _ in 1..<affixCount {
            guard let stat = pool.randomElement() else { break }
            pool.removeAll { $0 == stat }
            affixes.append(rolledAffix(for: stat, slot: slot, rarity: rarity, itemLevel: itemLevel))
        }
        return affixes
    }

    private static func rolledAffix(for stat: StatType, slot: GearSlot, rarity: Rarity, itemLevel: Int) -> GearAffix {
        let base = baseValue(for: stat, slot: slot)
        let value = base * Double(itemLevel) * rarity.statMultiplier * Double.random(in: 0.85...1.15)
        return GearAffix(stat: stat, value: value)
    }

    private static func baseValue(for stat: StatType, slot: GearSlot) -> Double {
        switch stat {
        case .attack: return slot == .weapon ? 1.2 : 0.4
        case .defense: return slot == .armor ? 0.9 : 0.3
        case .maxHP: return slot == .armor ? 6.0 : 2.0
        case .critChance: return 0.0015
        case .critDamage: return 0.003
        case .goldFind: return 0.004
        case .xpGain: return 0.004
        }
    }
}
