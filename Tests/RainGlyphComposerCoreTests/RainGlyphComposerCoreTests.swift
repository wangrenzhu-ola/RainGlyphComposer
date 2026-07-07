import XCTest
@testable import RainGlyphComposerCore

final class RainGlyphComposerCoreTests: XCTestCase {
    @MainActor
    func testCreateEditDeletePersistsRainGlyphScore() throws {
        let url = temporaryStoreURL()
        let store = RainGlyphStore(fileURL: url, starterExamples: [])
        let draft = RainGlyphDraft(
            title: "Kitchen Window Rain",
            tapFeeling: "soft kitchen window taps",
            domainTags: ["window", "quiet"],
            styleParams: RainGlyphStyleParams(density: 0.62, tempo: 0.44, shimmer: 0.58),
            localVisualRef: "manual-rain-tap"
        )

        let saved = try store.save(draft)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(saved.title, "Kitchen Window Rain")

        var editDraft = saved.draftForEditing
        editDraft.title = "Kitchen Window Rain Edited"
        editDraft.domainTags = ["window", "moss", "night"]
        let edited = try store.save(editDraft)
        XCTAssertEqual(edited.id, saved.id)
        XCTAssertEqual(edited.title, "Kitchen Window Rain Edited")

        let reloaded = RainGlyphStore(fileURL: url, starterExamples: [])
        XCTAssertEqual(reloaded.records.first?.title, "Kitchen Window Rain Edited")
        XCTAssertEqual(reloaded.records.first?.domainTags, ["moss", "night", "window"])

        try reloaded.delete(edited)
        let afterDelete = RainGlyphStore(fileURL: url, starterExamples: [])
        XCTAssertTrue(afterDelete.records.isEmpty)
    }

    @MainActor
    func testSimulatedSaveFailurePreservesDraftAndStore() throws {
        let store = RainGlyphStore(fileURL: temporaryStoreURL(), starterExamples: [])
        let draft = RainGlyphDraft(title: "Failure Test", tapFeeling: "fast roof drum", domainTags: ["roof"])

        XCTAssertThrowsError(try store.save(draft, simulateFailure: true)) { error in
            XCTAssertEqual(error as? RainGlyphStore.StoreError, .simulatedSaveFailure)
        }
        XCTAssertTrue(store.records.isEmpty)
        XCTAssertEqual(draft.title, "Failure Test")

        let saved = try store.save(draft, simulateFailure: false)
        XCTAssertEqual(saved.title, "Failure Test")
        XCTAssertEqual(store.records.count, 1)
    }

    func testSystemAssistedDraftParserIsEditableAndSpecific() {
        let draft = RainGlyphDraftParser.draft(from: "fast window taps with moss light")
        XCTAssertTrue(draft.title.contains("fast window taps"))
        XCTAssertTrue(draft.domainTags.contains("window"))
        XCTAssertGreaterThan(draft.styleParams.density, 0.1)
        XCTAssertEqual(draft.localVisualRef, "system-assisted-rain-tap")
    }

    private func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("rain-glyph-scores.json")
    }
}
