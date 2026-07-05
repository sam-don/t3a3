import Foundation

struct Hero: Codable, Equatable {
    var level: Int = 1
    var xp: Double = 0

    static let baseAttack: Double = 5
    static let baseDefense: Double = 2
    static let baseMaxHP: Double = 50
    static let baseCritChance: Double = 0.05
    static let baseCritDamage: Double = 1.5

    var xpToNextLevel: Double {
        Balance.xpRequired(forLevel: level)
    }

    /// Adds XP, rolling over as many level-ups as the amount allows.
    /// Returns the number of levels gained.
    @discardableResult
    mutating func addXP(_ amount: Double) -> Int {
        guard amount > 0 else { return 0 }
        var levelsGained = 0
        xp += amount
        while xp >= xpToNextLevel {
            xp -= xpToNextLevel
            level += 1
            levelsGained += 1
        }
        return levelsGained
    }
}
