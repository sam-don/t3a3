import Foundation

struct Enemy: Equatable {
    let floor: Int
    let name: String
    let maxHP: Double
    let attack: Double
    let defense: Double
    let isBoss: Bool
}
