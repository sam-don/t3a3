import Foundation

/// Everything that gets persisted to disk. A fresh `GameState()` is a brand
/// new save file — floor 1, level 1, empty inventory.
struct GameState: Codable, Equatable {
    var hero: Hero = Hero()
    var heroCurrentHP: Double = Hero.baseMaxHP

    var gold: Double = 0
    var gems: Double = 0
    var essence: Double = 0
    var skillPoints: Int = 0

    var currentFloor: Int = 1
    var maxFloorReached: Int = 1
    var currentEnemyHP: Double?

    var equippedGear: [GearSlot: GearItem] = [:]
    var inventory: [GearItem] = []

    /// Reset every prestige.
    var talentRanks: [String: Int] = [:]
    /// Never reset — the permanent meta-progression layer.
    var ascensionRanks: [String: Int] = [:]

    var prestigeCount: Int = 0
    var totalPlayTime: TimeInterval = 0

    var lastSaveDate: Date = Date()
    var lastTapDate: Date = .distantPast
}
