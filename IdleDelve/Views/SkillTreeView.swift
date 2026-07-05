import SwiftUI

struct SkillTreeView: View {
    @EnvironmentObject private var engine: GameEngine

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Skill Points", systemImage: "star.fill")
                        Spacer()
                        Text("\(engine.state.skillPoints)")
                            .fontWeight(.semibold)
                    }
                } footer: {
                    Text("Earn a skill point every time your hero levels up. Talents reset when you prestige.")
                }

                Section("Talents") {
                    ForEach(TalentTree.talents) { talent in
                        talentRow(talent)
                    }
                }
            }
            .navigationTitle("Skills")
        }
    }

    private func talentRow(_ talent: Talent) -> some View {
        let rank = engine.state.talentRanks[talent.id] ?? 0
        let maxed = rank >= talent.maxRank
        let cost = Int(talent.cost(atRank: rank).rounded(.up))

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(talent.name, systemImage: talent.stat.icon)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Rank \(rank)/\(talent.maxRank)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("+\(percentString(talent.valuePerRank)) \(talent.stat.displayName.lowercased()) per rank")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                ProgressBarView(fraction: Double(rank) / Double(talent.maxRank), tint: .purple)
                Button(maxed ? "Maxed" : "\(cost) SP") {
                    engine.purchaseTalent(talent.id)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(maxed || engine.state.skillPoints < cost)
            }
        }
        .padding(.vertical, 4)
    }

    private func percentString(_ value: Double) -> String {
        let percent = value * 100
        if percent < 1 {
            return String(format: "%.2f%%", percent)
        }
        return "\(Int(percent.rounded()))%"
    }
}
