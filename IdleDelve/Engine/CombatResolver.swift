import Foundation

enum CombatResolver {
    /// Defense mitigates damage but can never reduce a hit below 10% of raw attack.
    static func rollDamage(attack: Double, defense: Double, critChance: Double, critDamage: Double) -> (damage: Double, isCrit: Bool) {
        let mitigated = max(attack * 0.1, attack - defense)
        let isCrit = Double.random(in: 0...1) < critChance
        let damage = isCrit ? mitigated * critDamage : mitigated
        return (damage, isCrit)
    }

    static func rollEnemyDamage(attack: Double, defense: Double) -> Double {
        max(attack * 0.1, attack - defense)
    }
}
