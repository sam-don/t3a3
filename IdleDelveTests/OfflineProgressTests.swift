import XCTest
@testable import IdleDelve

final class OfflineProgressTests: XCTestCase {
    func testLongAbsenceAdvancesFloorsAndGrantsRewards() {
        let saveManager = SaveManager(directory: FileManager.default.temporaryDirectory, filename: "offline_test_\(UUID().uuidString).json")
        var state = GameState()
        state.currentFloor = 1
        state.maxFloorReached = 1
        state.lastSaveDate = Date().addingTimeInterval(-2 * 3600)
        saveManager.save(state)

        let engine = GameEngine(saveManager: saveManager)

        XCTAssertNotNil(engine.offlineReport)
        XCTAssertGreaterThan(engine.state.currentFloor, 1)
        XCTAssertGreaterThan(engine.state.gold, 0)
    }

    func testRecentSaveDoesNotTriggerOfflineReport() {
        let saveManager = SaveManager(directory: FileManager.default.temporaryDirectory, filename: "offline_test_\(UUID().uuidString).json")
        var state = GameState()
        state.lastSaveDate = Date()
        saveManager.save(state)

        let engine = GameEngine(saveManager: saveManager)
        XCTAssertNil(engine.offlineReport)
    }

    func testOfflineProgressIsCappedByMaxOfflineSeconds() {
        let saveManager = SaveManager(directory: FileManager.default.temporaryDirectory, filename: "offline_test_\(UUID().uuidString).json")
        var state = GameState()
        state.currentFloor = 1
        state.maxFloorReached = 1
        state.lastSaveDate = Date().addingTimeInterval(-100 * 3600) // far beyond the 8h cap
        saveManager.save(state)

        let engine = GameEngine(saveManager: saveManager)
        XCTAssertNotNil(engine.offlineReport)
        XCTAssertLessThanOrEqual(engine.offlineReport?.duration ?? 0, Balance.maxOfflineSeconds + 1)
    }
}
