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
                            .foregroundStyle(Theme.essence)
                        Text("\(Int(engine.state.essence)) essence banked")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))

                        if engine.canPrestige {
                            Text("Prestiging now grants +\(Int(engine.prestigeReward)) essence, but resets your floor, level, gold, talents, and gear.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Button("Prestige Now") {
                                showConfirmation = true
                            }
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Theme.essenceGradient))
                            .foregroundStyle(.white)
                            .buttonStyle(.plain)
                        } else {
                            Text("Reach floor \(Balance.prestigeFloorRequirement) (currently \(engine.state.maxFloorReached)) to unlock prestiging.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            ProgressBarView(
                                fraction: Double(engine.state.maxFloorReached) / Double(Balance.prestigeFloorRequirement),
                                tint: Theme.essence
                            )
                            .frame(height: 8)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(Theme.rowFill)

                Section {
                    ForEach(AscensionTree.upgrades) { upgrade in
                        ascensionRow(upgrade)
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    Text("ASCENSION")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.essence)
                } footer: {
                    Text("Permanent upgrades bought with essence. These never reset, even across prestiges.")
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .dungeonBackground()
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
        let affordable = engine.state.essence >= cost

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(upgrade.name, systemImage: upgrade.stat.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("Rank \(rank)/\(upgrade.maxRank)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            HStack(spacing: 10) {
                ProgressBarView(fraction: Double(rank) / Double(upgrade.maxRank), tint: Theme.essence)
                Button(maxed ? "Maxed" : "\(Int(cost.rounded(.up))) Essence") {
                    engine.purchaseAscension(upgrade.id)
                }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(maxed || !affordable ? Color.white.opacity(0.08) : Theme.essence.opacity(0.35))
                )
                .foregroundStyle(maxed || !affordable ? .white.opacity(0.4) : .white)
                .buttonStyle(.plain)
                .disabled(maxed || !affordable)
            }
        }
        .cardStyle()
    }
}
