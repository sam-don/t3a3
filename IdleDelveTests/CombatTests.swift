import XCTest
@testable import IdleDelve

final class CombatTests: XCTestCase {
    func testDamageNeverDropsBelowTenPercentOfAttack() {
        let (damage, _) = CombatResolver.rollDamage(attack: 100, defense: 500, critChance: 0, critDamage: 1.5)
        XCTAssertEqual(damage, 10, accuracy: 0.001)
    }

    func testZeroCritChanceNeverCrits() {
        let (damage, isCrit) = CombatResolver.rollDamage(attack: 100, defense: 20, critChance: 0, critDamage: 2.0)
        XCTAssertFalse(isCrit)
        XCTAssertEqual(damage, 80, accuracy: 0.001)
    }

    func testGuaranteedCritMultipliesDamage() {
        let (damage, isCrit) = CombatResolver.rollDamage(attack: 100, defense: 0, critChance: 1, critDamage: 2.0)
        XCTAssertTrue(isCrit)
        XCTAssertEqual(damage, 200, accuracy: 0.001)
    }

    func testEnemyDamageRespectsDefenseFloor() {
        let damage = CombatResolver.rollEnemyDamage(attack: 50, defense: 1000)
        XCTAssertEqual(damage, 5, accuracy: 0.001)
    }

    func testHeroStatsCombinesFlatGearAndMultiplicativeTalent() {
        var state = GameState()
        state.hero.level = 1
        state.equippedGear[.weapon] = GearItem(slot: .weapon, rarity: .common, itemLevel: 1, affixes: [GearAffix(stat: .attack, value: 10)])
        state.talentRanks["warriors_strength"] = 2 // +3% per rank

        let stats = HeroStats.compute(state: state)
        let expectedFlat = Hero.baseAttack + 10
        XCTAssertEqual(stats.attack, expectedFlat * 1.06, accuracy: 0.0001)
    }

    func testCritChanceTalentAddsAdditively() {
        var state = GameState()
        state.talentRanks["keen_eye"] = 4 // +0.5% per rank

        let stats = HeroStats.compute(state: state)
        XCTAssertEqual(stats.critChance, Hero.baseCritChance + 0.02, accuracy: 0.0001)
    }
}
