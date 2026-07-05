import SwiftUI

struct PrestigeView: View {
    @EnvironmentObject private var engine: GameEngine
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Essence", systemImage: "sparkle")
                            .font(.headline)
                        Text("\(Int(engine.state.essence)) essence banked")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if engine.canPrestige {
                            Text("Prestiging now grants +\(Int(engine.prestigeReward)) essence, but resets your floor, level, gold, talents, and gear.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button("Prestige Now") {
                                showConfirmation = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.pink)
                        } else {
                            Text("Reach floor \(Balance.prestigeFloorRequirement) (currently \(engine.state.maxFloorReached)) to unlock prestiging.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ProgressBarView(
                                fraction: Double(engine.state.maxFloorReached) / Double(Balance.prestigeFloorRequirement),
                                tint: .pink
                            )
                            .frame(height: 8)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section {
                    ForEach(AscensionTree.upgrades) { upgrade in
                        ascensionRow(upgrade)
                    }
                } header: {
                    Text("Ascension")
                } footer: {
                    Text("Permanent upgrades bought with essence. These never reset, even across prestiges.")
                }
            }
            .navigationTitle("Prestige")
            .alert("Prestige?", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Prestige", role: .destructive) {
                    engine.performPrestige()
                }
            } message: {
                Text("Your floor, level, gold, gear, and talents will reset. You'll keep essence and ascension upgrades.")
            }
        }
    }

    private func ascensionRow(_ upgrade: Talent) -> some View {
        let rank = engine.state.ascensionRanks[upgrade.id] ?? 0
        let maxed = rank >= upgrade.maxRank
        let cost = upgrade.cost(atRank: rank)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(upgrade.name, systemImage: upgrade.stat.icon)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Rank \(rank)/\(upgrade.maxRank)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                ProgressBarView(fraction: Double(rank) / Double(upgrade.maxRank), tint: .pink)
                Button(maxed ? "Maxed" : "\(Int(cost.rounded(.up))) Essence") {
                    engine.purchaseAscension(upgrade.id)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.pink)
                .disabled(maxed || engine.state.essence < cost)
            }
        }
        .padding(.vertical, 4)
    }
}
