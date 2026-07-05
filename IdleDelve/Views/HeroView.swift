import SwiftUI

struct HeroView: View {
    @EnvironmentObject private var engine: GameEngine

    var body: some View {
        NavigationStack {
            List {
                Section("Stats") {
                    StatRowView(stat: .attack, value: Int(engine.stats.attack).description)
                    StatRowView(stat: .defense, value: Int(engine.stats.defense).description)
                    StatRowView(stat: .maxHP, value: Int(engine.stats.maxHP).description)
                    StatRowView(stat: .critChance, value: percent(engine.stats.critChance))
                    StatRowView(stat: .critDamage, value: percent(engine.stats.critDamage - 1))
                    StatRowView(stat: .goldFind, value: percent(engine.stats.goldFind))
                    StatRowView(stat: .xpGain, value: percent(engine.stats.xpGain))
                }

                Section("Equipped") {
                    ForEach(GearSlot.allCases) { slot in
                        if let item = engine.state.equippedGear[slot] {
                            GearItemRow(item: item, isEquipped: true) {
                                engine.unequip(slot)
                            }
                        } else {
                            HStack {
                                Image(systemName: slot.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 32)
                                Text("No \(slot.displayName.lowercased()) equipped")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                    }
                }

                Section {
                    if engine.state.inventory.isEmpty {
                        Text("No items yet — keep delving.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(engine.state.inventory) { item in
                            GearItemRow(item: item, action: {
                                engine.equip(item)
                            }, secondaryAction: {
                                engine.sell(item)
                            })
                        }
                    }
                } header: {
                    HStack {
                        Text("Inventory (\(engine.state.inventory.count))")
                        Spacer()
                        Menu("Sell Junk") {
                            ForEach(Rarity.allCases) { rarity in
                                Button("Sell \(rarity.name) and below") {
                                    engine.sellAll(rarityAtMost: rarity)
                                }
                            }
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("Hero")
        }
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}
