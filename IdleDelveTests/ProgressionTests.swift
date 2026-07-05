import XCTest
@testable import IdleDelve

final class ProgressionTests: XCTestCase {
    func testAddXPRollsOverMultipleLevels() {
        var hero = Hero()
        let levels = hero.addXP(1000)
        XCTAssertGreaterThan(levels, 0)
        XCTAssertEqual(hero.level, 1 + levels)
        XCTAssertLessThan(hero.xp, hero.xpToNextLevel)
    }

    func testXPRequiredIncreasesWithLevel() {
        let low = Balance.xpRequired(forLevel: 1)
        let high = Balance.xpRequired(forLevel: 20)
        XCTAssertLessThan(low, high)
    }

    func testTalentCostGrowsWithRank() {
        guard let talent = TalentTree.talent(id: "warriors_strength") else {
            return XCTFail("Expected talent to exist")
        }
        XCTAssertGreaterThan(talent.cost(atRank: 10), talent.cost(atRank: 0))
    }

    func testGenerateAffixesIncludesPrimaryStatWithNoDuplicates() {
        let affixes = LootTable.generateAffixes(slot: .weapon, rarity: .legendary, itemLevel: 10)
        XCTAssertTrue(affixes.contains { $0.stat == .attack })
        XCTAssertEqual(Set(affixes.map(\.stat)).count, affixes.count)
        XCTAssertLessThanOrEqual(affixes.count, 3)
    }

    func testSellValueScalesWithRarity() {
        let common = GearItem(slot: .weapon, rarity: .common, itemLevel: 5, affixes: [])
        let legendary = GearItem(slot: .weapon, rarity: .legendary, itemLevel: 5, affixes: [])
        XCTAssertGreaterThan(legendary.sellValue, common.sellValue)
    }

    func testPrestigeResetsRunButKeepsEssenceAndAscension() {
        let saveManager = SaveManager(directory: FileManager.default.temporaryDirectory, filename: "prestige_test_\(UUID().uuidString).json")
        var state = GameState()
        state.maxFloorReached = 30
        state.currentFloor = 30
        state.hero.level = 10
        state.gold = 500
        state.ascensionRanks["ascendant_power"] = 3
        state.lastSaveDate = Date()
        saveManager.save(state)

        let engine = GameEngine(saveManager: saveManager)
        XCTAssertTrue(engine.canPrestige)

        let expectedReward = engine.prestigeReward
        engine.performPrestige()

        XCTAssertEqual(engine.state.currentFloor, 1)
        XCTAssertEqual(engine.state.hero.level, 1)
        XCTAssertEqual(engine.state.gold, 0)
        XCTAssertEqual(engine.state.prestigeCount, 1)
        XCTAssertEqual(engine.state.essence, expectedReward)
        XCTAssertEqual(engine.state.ascensionRanks["ascendant_power"], 3)
    }
}
