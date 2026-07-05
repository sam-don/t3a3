import SwiftUI
import SpriteKit

struct DungeonView: View {
    @EnvironmentObject private var engine: GameEngine
    @State private var scene = BattleScene(size: CGSize(width: 340, height: 220))

    private var zone: Zone { Zone.forFloor(engine.state.currentFloor) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    battleStage
                    heroHUD
                }
                .padding()
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Idle Delve")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    CurrencyBadge(systemImage: "dollarsign.circle.fill", value: engine.state.gold, tint: Theme.gold)
                    CurrencyBadge(systemImage: "sparkle", value: engine.state.essence, tint: Theme.essence)
                }
            }
        }
        .onChange(of: engine.currentEnemy) { enemy in
            scene.configureEnemy(enemy, hp: engine.enemyHP, zoneHue: zone.hue)
        }
        .onChange(of: engine.lastEvent) { event in
            handle(event)
        }
        .onAppear {
            scene.configureEnemy(engine.currentEnemy, hp: engine.enemyHP, zoneHue: zone.hue)
        }
        .sheet(item: $engine.offlineReport) { report in
            OfflineReportSheet(report: report) {
                engine.dismissOfflineReport()
            }
            .presentationDetents([.medium])
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(engine.state.hero.level)")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                Text("Max Floor \(engine.state.maxFloorReached)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            CurrencyBadge(systemImage: "star.fill", value: Double(engine.state.skillPoints), tint: Theme.xpColor)
        }
    }

    private var battleStage: some View {
        VStack(spacing: 10) {
            Text("\(zone.name) — Floor \(engine.state.currentFloor)")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(.white)

            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Theme.cardStroke, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                .onTapGesture {
                    engine.tapAttack()
                }

            TimelineView(.periodic(from: .now, by: 0.1)) { _ in
                let remaining = engine.tapCooldownRemaining
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text(remaining > 0.05 ? "Ready in \(String(format: "%.1f", remaining))s" : "Tap the stage for a bonus strike!")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(remaining > 0.05 ? .white.opacity(0.4) : Theme.essence)
            }
        }
    }

    private var heroHUD: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label("Hero HP", systemImage: "heart.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(engine.state.heroCurrentHP)) / \(Int(engine.stats.maxHP))")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.white)
                }
                ProgressBarView(fraction: hpFraction, tint: hpFraction > 0.3 ? Theme.hp : Theme.hpLow)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label("XP", systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(engine.state.hero.xp)) / \(Int(engine.state.hero.xpToNextLevel))")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.white)
                }
                ProgressBarView(fraction: xpFraction, tint: Theme.xpColor)
            }

            HStack {
                StatRowView(stat: .attack, value: Int(engine.stats.attack).description)
                StatRowView(stat: .defense, value: Int(engine.stats.defense).description)
            }
        }
        .cardStyle()
    }

    private var hpFraction: Double {
        engine.stats.maxHP > 0 ? engine.state.heroCurrentHP / engine.stats.maxHP : 0
    }

    private var xpFraction: Double {
        engine.state.hero.xpToNextLevel > 0 ? engine.state.hero.xp / engine.state.hero.xpToNextLevel : 0
    }

    private func handle(_ event: CombatEvent?) {
        guard let event else { return }
        switch event {
        case let .heroHit(damage, isCrit):
            scene.heroAttacked(damage: damage, isCrit: isCrit)
            scene.updateEnemyHP(engine.enemyHP, maxHP: engine.currentEnemy.maxHP)
        case let .enemyHit(damage):
            scene.enemyAttacked(damage: damage)
        case .enemyDefeated, .lootDropped:
            scene.enemyDefeated()
        case .heroDefeated:
            break
        }
    }
}
