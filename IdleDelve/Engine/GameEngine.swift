import Foundation
import Combine

/// Drives the whole idle loop: a repeating timer trades attacks between hero
/// and enemy, resolves kills/loot/level-ups, and persists state. All mutation
/// happens through this object so SwiftUI views can just observe it.
final class GameEngine: ObservableObject {
    @Published private(set) var state: GameState
    @Published private(set) var currentEnemy: Enemy
    @Published private(set) var enemyHP: Double
    @Published private(set) var stats: HeroStats
    @Published var lastEvent: CombatEvent?
    @Published var offlineReport: OfflineReport?

    private let saveManager: SaveManager
    private var timer: Timer?
    private var heroAttackAccumulator: TimeInterval = 0
    private var enemyAttackAccumulator: TimeInterval = 0
    private var autosaveAccumulator: TimeInterval = 0

    init(saveManager: SaveManager = SaveManager()) {
        self.saveManager = saveManager
        let loaded = saveManager.load() ?? GameState()
        state = loaded
        let enemy = Balance.enemy(forFloor: loaded.currentFloor)
        currentEnemy = enemy
        enemyHP = loaded.currentEnemyHP ?? enemy.maxHP
        stats = HeroStats.zero
        stats = HeroStats.compute(state: state)
        applyOfflineProgress()
    }

    // MARK: - Lifecycle

    func start() {
        guard timer == nil else { return }
        let newTimer = Timer(timeInterval: 1.0 / 10.0, repeats: true) { [weak self] _ in
            self?.tick(dt: 1.0 / 10.0)
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        persist()
    }

    func dismissOfflineReport() {
        offlineReport = nil
    }

    // MARK: - Tick

    private func tick(dt: TimeInterval) {
        state.totalPlayTime += dt
        heroAttackAccumulator += dt
        enemyAttackAccumulator += dt

        if state.heroCurrentHP < stats.maxHP {
            state.heroCurrentHP = min(stats.maxHP, state.heroCurrentHP + stats.maxHP * Balance.heroRegenPerSecond * dt)
        }

        if heroAttackAccumulator >= Balance.attackInterval {
            heroAttackAccumulator -= Balance.attackInterval
            performHeroAttack()
        }
        if enemyHP > 0 && enemyAttackAccumulator >= Balance.attackInterval {
            enemyAttackAccumulator -= Balance.attackInterval
            performEnemyAttack()
        }

        autosaveAccumulator += dt
        if autosaveAccumulator > 15 {
            autosaveAccumulator = 0
            persist()
        }
    }

    // MARK: - Combat

    private func performHeroAttack() {
        let (damage, isCrit) = CombatResolver.rollDamage(
            attack: stats.attack,
            defense: currentEnemy.defense,
            critChance: stats.critChance,
            critDamage: stats.critDamage
        )
        enemyHP = max(0, enemyHP - damage)
        lastEvent = .heroHit(damage: damage, isCrit: isCrit)
        if enemyHP <= 0 {
            handleEnemyDefeated()
        }
    }

    private func performEnemyAttack() {
        let damage = CombatResolver.rollEnemyDamage(attack: currentEnemy.attack, defense: stats.defense)
        state.heroCurrentHP = max(0, state.heroCurrentHP - damage)
        lastEvent = .enemyHit(damage: damage)
        if state.heroCurrentHP <= 0 {
            handleHeroDefeated()
        }
    }

    /// Manual tap for a bonus hit on a short cooldown — the one bit of active
    /// engagement layered on top of the otherwise passive auto-battle.
    func tapAttack() {
        guard enemyHP > 0, tapCooldownRemaining <= 0 else { return }
        state.lastTapDate = Date()
        let (damage, isCrit) = CombatResolver.rollDamage(
            attack: stats.attack * Balance.tapDamageMultiplier,
            defense: currentEnemy.defense,
            critChance: stats.critChance,
            critDamage: stats.critDamage
        )
        enemyHP = max(0, enemyHP - damage)
        lastEvent = .heroHit(damage: damage, isCrit: isCrit)
        if enemyHP <= 0 {
            handleEnemyDefeated()
        }
    }

    var tapCooldownRemaining: TimeInterval {
        max(0, Balance.tapCooldown - Date().timeIntervalSince(state.lastTapDate))
    }

    private func handleEnemyDefeated() {
        let goldReward = Balance.goldReward(forFloor: state.currentFloor, isBoss: currentEnemy.isBoss) * (1 + stats.goldFind)
        let xpReward = Balance.xpReward(forFloor: state.currentFloor, isBoss: currentEnemy.isBoss) * (1 + stats.xpGain)

        state.gold += goldReward
        let levelsGained = state.hero.addXP(xpReward)
        if levelsGained > 0 {
            state.skillPoints += levelsGained
            refreshStats(fullHeal: true)
        }

        if let drop = LootTable.rollDrop(forFloor: state.currentFloor, isBoss: currentEnemy.isBoss) {
            state.inventory.append(drop)
            lastEvent = .lootDropped(drop)
        } else {
            lastEvent = .enemyDefeated(gold: goldReward, xp: xpReward)
        }

        advanceFloor()
    }

    private func handleHeroDefeated() {
        // Idle-friendly failure: retreat a few floors and keep going, rather
        // than a hard game-over.
        state.currentFloor = max(1, state.currentFloor - 3)
        syncEnemyToCurrentFloor()
        state.heroCurrentHP = stats.maxHP
        lastEvent = .heroDefeated(retreatedToFloor: state.currentFloor)
    }

    private func advanceFloor() {
        state.currentFloor += 1
        state.maxFloorReached = max(state.maxFloorReached, state.currentFloor)
        syncEnemyToCurrentFloor()
    }

    private func syncEnemyToCurrentFloor() {
        currentEnemy = Balance.enemy(forFloor: state.currentFloor)
        enemyHP = currentEnemy.maxHP
        heroAttackAccumulator = 0
        enemyAttackAccumulator = 0
    }

    private func refreshStats(fullHeal: Bool = false) {
        let previousMaxHP = stats.maxHP
        let hpFraction = previousMaxHP > 0 ? state.heroCurrentHP / previousMaxHP : 1
        stats = HeroStats.compute(state: state)
        state.heroCurrentHP = fullHeal ? stats.maxHP : min(stats.maxHP, stats.maxHP * hpFraction)
    }

    // MARK: - Gear

    func equip(_ item: GearItem) {
        if let existing = state.equippedGear[item.slot] {
            state.inventory.append(existing)
        }
        state.equippedGear[item.slot] = item
        state.inventory.removeAll { $0.id == item.id }
        refreshStats()
        persist()
    }

    func unequip(_ slot: GearSlot) {
        guard let item = state.equippedGear[slot] else { return }
        state.inventory.append(item)
        state.equippedGear[slot] = nil
        refreshStats()
        persist()
    }

    func sell(_ item: GearItem) {
        guard let index = state.inventory.firstIndex(where: { $0.id == item.id }) else { return }
        state.gold += Double(item.sellValue)
        state.inventory.remove(at: index)
    }

    func sellAll(rarityAtMost rarity: Rarity) {
        let toSell = state.inventory.filter { $0.rarity <= rarity }
        state.gold += toSell.reduce(0) { $0 + Double($1.sellValue) }
        state.inventory.removeAll { $0.rarity <= rarity }
    }

    // MARK: - Talents & Ascension

    func purchaseTalent(_ id: String) {
        guard let talent = TalentTree.talent(id: id) else { return }
        let rank = state.talentRanks[id] ?? 0
        guard rank < talent.maxRank else { return }
        let cost = Int(talent.cost(atRank: rank).rounded(.up))
        guard state.skillPoints >= cost else { return }
        state.skillPoints -= cost
        state.talentRanks[id, default: 0] += 1
        refreshStats()
        persist()
    }

    func purchaseAscension(_ id: String) {
        guard let upgrade = AscensionTree.upgrade(id: id) else { return }
        let rank = state.ascensionRanks[id] ?? 0
        guard rank < upgrade.maxRank else { return }
        let cost = upgrade.cost(atRank: rank)
        guard state.essence >= cost else { return }
        state.essence -= cost
        state.ascensionRanks[id, default: 0] += 1
        refreshStats()
        persist()
    }

    // MARK: - Prestige

    var canPrestige: Bool {
        state.maxFloorReached >= Balance.prestigeFloorRequirement
    }

    var prestigeReward: Double {
        Balance.essenceReward(forMaxFloor: state.maxFloorReached)
    }

    func performPrestige() {
        guard canPrestige else { return }
        state.essence += prestigeReward
        state.prestigeCount += 1
        state.hero = Hero()
        state.gold = 0
        state.currentFloor = 1
        state.maxFloorReached = 1
        state.equippedGear = [:]
        state.inventory = []
        state.talentRanks = [:]
        state.skillPoints = 0
        // ascensionRanks and essence intentionally survive the reset.
        syncEnemyToCurrentFloor()
        refreshStats(fullHeal: true)
        persist()
    }

    // MARK: - Offline progress

    private func applyOfflineProgress() {
        let elapsed = min(Date().timeIntervalSince(state.lastSaveDate), Balance.maxOfflineSeconds)
        guard elapsed > Balance.minOfflineSecondsToReport else { return }

        let effectiveSeconds = elapsed * Balance.offlineEfficiency
        let secondsPerKill = estimatedSecondsPerKill()
        var remainingKills = effectiveSeconds / secondsPerKill

        var floor = state.currentFloor
        var goldEarned: Double = 0
        var xpEarned: Double = 0
        var lootFound: [GearItem] = []

        while remainingKills > 0 && floor - state.currentFloor < Balance.maxOfflineFloorsSimulated {
            let isBoss = floor % Zone.floorsPerZone == 0
            goldEarned += Balance.goldReward(forFloor: floor, isBoss: isBoss)
            xpEarned += Balance.xpReward(forFloor: floor, isBoss: isBoss)
            if lootFound.count < 20, let drop = LootTable.rollDrop(forFloor: floor, isBoss: isBoss) {
                lootFound.append(drop)
            }
            floor += 1
            remainingKills -= 1
        }

        guard floor > state.currentFloor else { return }

        goldEarned *= (1 + stats.goldFind)
        xpEarned *= (1 + stats.xpGain)
        let floorsCleared = floor - state.currentFloor

        state.gold += goldEarned
        let levelsGained = state.hero.addXP(xpEarned)
        state.skillPoints += levelsGained
        state.inventory.append(contentsOf: lootFound)
        state.currentFloor = floor
        state.maxFloorReached = max(state.maxFloorReached, floor)

        if levelsGained > 0 {
            stats = HeroStats.compute(state: state)
        }
        syncEnemyToCurrentFloor()
        state.heroCurrentHP = stats.maxHP

        offlineReport = OfflineReport(duration: elapsed, gold: goldEarned, xp: xpEarned, floorsCleared: floorsCleared, loot: lootFound)
    }

    /// Rough average time to kill the current enemy, used only to pace the
    /// offline simulation loop — not exact (doesn't account for the hero
    /// growing stronger mid-simulation), but close enough for an estimate.
    private func estimatedSecondsPerKill() -> Double {
        let effectiveHit = max(1, stats.attack * (1 + stats.critChance * (stats.critDamage - 1)) - currentEnemy.defense)
        let hitsNeeded = currentEnemy.maxHP / effectiveHit
        return max(0.5, hitsNeeded * Balance.attackInterval)
    }

    // MARK: - Persistence

    func persist() {
        state.lastSaveDate = Date()
        state.currentEnemyHP = enemyHP
        saveManager.save(state)
    }
}
