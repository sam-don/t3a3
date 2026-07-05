import SwiftUI

struct SkillTreeView: View {
    @EnvironmentObject private var engine: GameEngine

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Skill Points", systemImage: "star.fill")
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(engine.state.skillPoints)")
                            .font(.headline)
                            .foregroundStyle(Theme.essence)
                    }
                } footer: {
                    Text("Earn a skill point every time your hero levels up. Talents reset when you prestige.")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .listRowBackground(Theme.rowFill)

                Section {
                    ForEach(TalentTree.talents) { talent in
                        talentRow(talent)
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    Text("TALENTS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.essence)
                }
            }
            .dungeonBackground()
            .navigationTitle("Skills")
        }
    }

    private func talentRow(_ talent: Talent) -> some View {
        let rank = engine.state.talentRanks[talent.id] ?? 0
        let maxed = rank >= talent.maxRank
        let cost = Int(talent.cost(atRank: rank).rounded(.up))

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(talent.name, systemImage: talent.stat.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("Rank \(rank)/\(talent.maxRank)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Text("+\(percentString(talent.valuePerRank)) \(talent.stat.displayName.lowercased()) per rank")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
            HStack(spacing: 10) {
                ProgressBarView(fraction: Double(rank) / Double(talent.maxRank), tint: Theme.xpColor)
                Button(maxed ? "Maxed" : "\(cost) SP") {
                    engine.purchaseTalent(talent.id)
                }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(maxed || engine.state.skillPoints < cost ? Color.white.opacity(0.08) : Theme.xpColor.opacity(0.35))
                )
                .foregroundStyle(maxed || engine.state.skillPoints < cost ? .white.opacity(0.4) : .white)
                .buttonStyle(.plain)
                .disabled(maxed || engine.state.skillPoints < cost)
            }
        }
        .cardStyle()
    }

    private func percentString(_ value: Double) -> String {
        let percent = value * 100
        if percent < 1 {
            return String(format: "%.2f%%", percent)
        }
        return "\(Int(percent.rounded()))%"
    }
}
