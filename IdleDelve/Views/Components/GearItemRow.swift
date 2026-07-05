import SwiftUI

struct GearItemRow: View {
    let item: GearItem
    var isEquipped: Bool = false
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: item.slot.icon)
                .font(.title3)
                .foregroundStyle(item.rarity.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(item.rarity.color)
                Text(affixSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if let secondaryAction {
                Button(action: secondaryAction) {
                    Image(systemName: "dollarsign.circle")
                }
                .buttonStyle(.borderless)
                .tint(.secondary)
            }

            if let action {
                Button(isEquipped ? "Unequip" : "Equip", action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(isEquipped ? .red : .accentColor)
            }
        }
        .padding(.vertical, 4)
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
