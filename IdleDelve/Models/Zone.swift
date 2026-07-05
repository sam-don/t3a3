import Foundation

/// Floors are grouped into themed zones of 10. The dungeon is endless, so
/// beyond the hand-authored zones we keep generating "Depth N" zones with a
/// procedurally rotating hue rather than hard-stopping content.
struct Zone: Equatable {
    let name: String
    /// Hue (0...1) used by the views/SpriteKit scene to tint the zone's look.
    let hue: Double

    static let floorsPerZone = 10

    private static let namedZones: [Zone] = [
        Zone(name: "Mossy Entrance", hue: 0.33),
        Zone(name: "Sunken Crypt", hue: 0.58),
        Zone(name: "Ember Hollow", hue: 0.05),
        Zone(name: "Frostvein Caves", hue: 0.55),
        Zone(name: "Shadowed Archives", hue: 0.75),
        Zone(name: "Molten Depths", hue: 0.02),
        Zone(name: "Voidglass Chasm", hue: 0.83),
        Zone(name: "The Abyssal Throne", hue: 0.95)
    ]

    static func forFloor(_ floor: Int) -> Zone {
        let zoneIndex = (max(1, floor) - 1) / floorsPerZone
        if zoneIndex < namedZones.count {
            return namedZones[zoneIndex]
        }
        let depthNumber = zoneIndex - namedZones.count + 2
        let hue = (Double(zoneIndex) * 0.618).truncatingRemainder(dividingBy: 1.0)
        return Zone(name: "Depth \(depthNumber)", hue: hue)
    }
}
