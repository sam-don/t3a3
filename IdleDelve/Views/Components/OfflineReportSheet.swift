import SwiftUI

struct OfflineReportSheet: View {
    let report: OfflineReport
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.essence)

            Text("Welcome Back")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.white)

            Text("Your hero delved on without you for \(formattedDuration).")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                offlineStatRow(icon: "dollarsign.circle.fill", label: "Gold earned", value: report.gold.abbreviated(), tint: Theme.gold)
                offlineStatRow(icon: "star.fill", label: "XP earned", value: report.xp.abbreviated(), tint: Theme.xpColor)
                offlineStatRow(icon: "figure.stairs", label: "Floors cleared", value: "\(report.floorsCleared)", tint: .blue)
                if !report.loot.isEmpty {
                    offlineStatRow(icon: "shippingbox.fill", label: "Items found", value: "\(report.loot.count)", tint: Theme.hp)
                }
            }
            .cardStyle()

            Button("Continue", action: onDismiss)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(Theme.essenceGradient))
                .foregroundStyle(.white)
                .buttonStyle(.plain)
        }
        .padding(24)
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var formattedDuration: String {
        let hours = Int(report.duration) / 3600
        let minutes = (Int(report.duration) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func offlineStatRow(icon: String, label: String, value: String, tint: Color) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(tint)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(.white)
        }
    }
}
