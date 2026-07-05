import SwiftUI

struct StatRowView: View {
    let stat: StatType
    let value: String

    var body: some View {
        HStack {
            Label(stat.displayName, systemImage: stat.icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}
