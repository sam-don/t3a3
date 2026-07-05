import Foundation

struct GearAffix: Codable, Equatable, Identifiable {
    var id: String { stat.rawValue }
    let stat: StatType
    let value: Double
}

struct GearItem: Identifiable, Codable, Equatable {
    let id: UUID
    let slot: GearSlot
    let rarity: Rarity
    let itemLevel: Int
    let affixes: [GearAffix]
    let name: String

    init(slot: GearSlot, rarity: Rarity, itemLevel: Int, affixes: [GearAffix], name: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.slot = slot
        self.rarity = rarity
        self.itemLevel = itemLevel
        self.affixes = affixes
        self.name = name ?? GearItem.generateName(slot: slot, rarity: rarity)
    }

    var sellValue: Int {
        let base = 8.0 * Double(itemLevel) * rarity.statMultiplier
        return max(1, Int(base.rounded()))
    }

    static func generateName(slot: GearSlot, rarity: Rarity) -> String {
        "\(rarity.name) \(slot.displayName)"
    }
}
