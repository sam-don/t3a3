import Foundation

/// A one-shot combat occurrence, published by the engine so the SwiftUI and
/// SpriteKit layers can react (damage popups, hit flashes, loot toasts)
/// without polling state every frame.
enum CombatEvent: Equatable {
    case heroHit(damage: Double, isCrit: Bool)
    case enemyHit(damage: Double)
    case enemyDefeated(gold: Double, xp: Double)
    case lootDropped(GearItem)
    case heroDefeated(retreatedToFloor: Int)
}

struct OfflineReport: Identifiable, Equatable {
    let id = UUID()
    let duration: TimeInterval
    let gold: Double
    let xp: Double
    let floorsCleared: Int
    let loot: [GearItem]
}
