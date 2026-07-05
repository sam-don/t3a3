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
            .navigationTitle("Idle Delve")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    CurrencyBadge(systemImage: "dollarsign.circle.fill", value: engine.state.gold, tint: .yellow)
                    CurrencyBadge(systemImage: "sparkle", value: engine.state.essence, tint: .pink)
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
                    .font(.subheadline.weight(.semibold))
                Text("Max Floor \(engine.state.maxFloorReached)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            CurrencyBadge(systemImage: "star.fill", value: Double(engine.state.skillPoints), tint: .purple)
        }
    }

    private var battleStage: some View {
        VStack(spacing: 8) {
            Text("\(zone.name) — Floor \(engine.state.currentFloor)")
                .font(.headline)

            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(height: 220)
                .background(Color.black.opacity(0.15), in: RoundedRectangle(cornerRadius: 20))
                .onTapGesture {
                    engine.tapAttack()
                }

            TimelineView(.periodic(from: .now, by: 0.1)) { _ in
                let remaining = engine.tapCooldownRemaining
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text(remaining > 0.05 ? "Ready in \(String(format: "%.1f", remaining))s" : "Tap the stage for a bonus strike!")
                }
                .font(.caption)
                .foregroundStyle(remaining > 0.05 ? .secondary : Color.accentColor)
            }
        }
    }

    private var heroHUD: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label("Hero HP", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(engine.state.heroCurrentHP)) / \(Int(engine.stats.maxHP))")
                        .font(.caption.monospacedDigit())
                }
                ProgressBarView(fraction: hpFraction, tint: .green)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label("XP", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(engine.state.hero.xp)) / \(Int(engine.state.hero.xpToNextLevel))")
                        .font(.caption.monospacedDigit())
                }
                ProgressBarView(fraction: xpFraction, tint: .purple)
            }

            HStack {
                StatRowView(stat: .attack, value: Int(engine.stats.attack).description)
                StatRowView(stat: .defense, value: Int(engine.stats.defense).description)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
