import SwiftUI

struct OfflineReportSheet: View {
    let report: OfflineReport
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.title2.bold())

            Text("Your hero delved on without you for \(formattedDuration).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                offlineStatRow(icon: "dollarsign.circle.fill", label: "Gold earned", value: report.gold.abbreviated(), tint: .yellow)
                offlineStatRow(icon: "star.fill", label: "XP earned", value: report.xp.abbreviated(), tint: .purple)
                offlineStatRow(icon: "figure.stairs", label: "Floors cleared", value: "\(report.floorsCleared)", tint: .blue)
                if !report.loot.isEmpty {
                    offlineStatRow(icon: "shippingbox.fill", label: "Items found", value: "\(report.loot.count)", tint: .green)
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

            Button("Continue", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding(24)
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
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }
}
