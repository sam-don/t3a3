import Foundation

extension Double {
    /// Abbreviates large idle-game numbers, e.g. 12_345 -> "12.3K".
    func abbreviated(decimals: Int = 1) -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        func fmt(_ value: Double) -> String { String(format: "%.\(decimals)f", value) }

        switch absValue {
        case 0..<1_000:
            return "\(sign)\(Int(absValue))"
        case 1_000..<1_000_000:
            return "\(sign)\(fmt(absValue / 1_000))K"
        case 1_000_000..<1_000_000_000:
            return "\(sign)\(fmt(absValue / 1_000_000))M"
        case 1_000_000_000..<1_000_000_000_000:
            return "\(sign)\(fmt(absValue / 1_000_000_000))B"
        default:
            return "\(sign)\(fmt(absValue / 1_000_000_000_000))T"
        }
    }
}
