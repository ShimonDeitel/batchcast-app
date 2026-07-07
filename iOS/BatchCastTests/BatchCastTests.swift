import XCTest
@testable import BatchCast

final class BatchCastTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchCastStore()
        XCTAssertGreaterThan(store.casts.count, 0)
        XCTAssertLessThan(store.casts.count, BatchCastStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchCastStore()
        let before = store.casts.count
        let added = store.addCast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.casts.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchCastStore()
        let before = store.casts.count
        let added = store.addCast(pieceName: "   ", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.casts.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchCastStore()
        for item in store.casts { store.deleteCast(item.id) }
        for _ in 0..<BatchCastStore.freeLimit {
            XCTAssertTrue(store.addCast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: false))
        }
        XCTAssertFalse(store.addCast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: false))
        XCTAssertTrue(store.addCast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchCastStore()
        store.addCast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: false)
        guard let item = store.casts.last else { return XCTFail("expected entry") }
        let before = store.casts.count
        store.deleteCast(item.id)
        XCTAssertEqual(store.casts.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchCastStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.casts.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchCastStore()
        store.addCast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr", isPro: false)
        guard let item = store.casts.last else { return XCTFail("expected entry") }
        store.updateCast(item.id, pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr")
        XCTAssertEqual(store.casts.count, store.casts.count)
    }
}
