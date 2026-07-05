import Foundation

/// Every tunable game-balance formula lives here so difficulty/economy can
/// be retuned without touching engine logic.
enum Balance {
    // MARK: - Leveling
    static func xpRequired(forLevel level: Int) -> Double {
        20 * pow(Double(level), 1.45)
    }

    // MARK: - Enemy scaling
    static func enemy(forFloor floor: Int) -> Enemy {
        let f = Double(floor)
        let isBoss = floor % Zone.floorsPerZone == 0
        let bossHPMultiplier = isBoss ? 4.0 : 1.0
        let bossAttackMultiplier = isBoss ? 1.6 : 1.0
        let maxHP = (18 * pow(f, 1.32) + 12) * bossHPMultiplier
        let attack = (2.2 * pow(f, 1.18) + 3) * bossAttackMultiplier
        let defense = 0.8 * pow(f, 1.1)
        let zone = Zone.forFloor(floor)
        let name = isBoss ? "\(zone.name) Guardian" : "\(zone.name) Dweller"
        return Enemy(floor: floor, name: name, maxHP: maxHP, attack: attack, defense: defense, isBoss: isBoss)
    }

    // MARK: - Rewards
    static func goldReward(forFloor floor: Int, isBoss: Bool) -> Double {
        let base = 4 * pow(Double(floor), 1.1) + 3
        return isBoss ? base * 5 : base
    }

    static func xpReward(forFloor floor: Int, isBoss: Bool) -> Double {
        let base = 3 * pow(Double(floor), 1.15) + 2
        return isBoss ? base * 4 : base
    }

    // MARK: - Combat pacing
    static let attackInterval: TimeInterval = 1.1
    static let heroRegenPerSecond: Double = 0.02 // fraction of max HP regenerated per second while idle

    // MARK: - Active tap ability
    static let tapCooldown: TimeInterval = 3.0
    static let tapDamageMultiplier: Double = 3.0

    // MARK: - Prestige
    static let prestigeFloorRequirement = 25

    static func essenceReward(forMaxFloor floor: Int) -> Double {
        guard floor >= prestigeFloorRequirement else { return 0 }
        return (Double(floor - (prestigeFloorRequirement - 1)) * 1.5).rounded(.down)
    }

    // MARK: - Offline progress
    static let maxOfflineSeconds: TimeInterval = 8 * 3600
    static let minOfflineSecondsToReport: TimeInterval = 30
    /// Progress accrues slower while away than while actively watching.
    static let offlineEfficiency: Double = 0.6
    static let maxOfflineFloorsSimulated = 2000
}
