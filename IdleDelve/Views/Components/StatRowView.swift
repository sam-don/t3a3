import SwiftUI

struct StatRowView: View {
    let stat: StatType
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: stat.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.essence)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.white.opacity(0.08)))
            Text(stat.displayName)
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .font(.subheadline)
    }
}
