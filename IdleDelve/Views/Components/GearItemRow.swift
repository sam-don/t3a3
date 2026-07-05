import SwiftUI

struct GearItemRow: View {
    let item: GearItem
    var isEquipped: Bool = false
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.rarity.color.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: item.slot.icon)
                    .font(.headline)
                    .foregroundStyle(item.rarity.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(item.rarity.color)
                Text(affixSummary)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if let secondaryAction {
                Button(action: secondaryAction) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.gold)
                }
                .buttonStyle(.plain)
            }

            if let action {
                Button(isEquipped ? "Unequip" : "Equip", action: action)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill(isEquipped ? Color.red.opacity(0.25) : Theme.essence.opacity(0.28))
                    )
                    .foregroundStyle(isEquipped ? .red : Theme.essence)
                    .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(item.rarity.color.opacity(0.4), lineWidth: 1)
        )
    }

    private var affixSummary: String {
        item.affixes.map { affix in
            let value = affix.stat.isPercentLike
                ? "\(Int((affix.value * 100).rounded()))%"
                : "\(Int(affix.value.rounded()))"
            return "\(affix.stat.displayName) +\(value)"
        }.joined(separator: " · ")
    }
}
