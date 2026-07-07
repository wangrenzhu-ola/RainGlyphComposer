import Foundation
import Combine

@MainActor
public final class RainGlyphStore: ObservableObject {
    public enum StoreError: LocalizedError, Equatable {
        case simulatedSaveFailure
        case missingTitle

        public var errorDescription: String? {
            switch self {
            case .simulatedSaveFailure:
                "Could not save the rain glyph score. Your draft is still here."
            case .missingTitle:
                "Give this rain glyph score a title before saving."
            }
        }
    }

    @Published public private(set) var records: [RainGlyphScoreRecord]
    public let starterExamples: [StarterExample]
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL? = nil, starterExamples: [StarterExample]? = nil) {
        self.fileURL = fileURL ?? Self.defaultStoreURL()
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        self.starterExamples = starterExamples ?? Self.loadStarterExamples()
        self.records = []
        load()
    }

    public func save(_ draft: RainGlyphDraft, simulateFailure: Bool = false) throws -> RainGlyphScoreRecord {
        if simulateFailure { throw StoreError.simulatedSaveFailure }
        let trimmedTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { throw StoreError.missingTitle }

        let now = Date()
        let normalizedTags = Self.normalizedTags(from: draft)
        let saved: RainGlyphScoreRecord
        if let id = draft.id, let index = records.firstIndex(where: { $0.id == id }) {
            var updated = records[index]
            updated.title = trimmedTitle
            updated.localVisualRef = draft.localVisualRef
            updated.domainTags = normalizedTags
            updated.styleParams = draft.styleParams
            updated.updatedAt = now
            updated.favorite = draft.favorite
            records[index] = updated
            saved = updated
        } else {
            saved = RainGlyphScoreRecord(
                title: trimmedTitle,
                localVisualRef: draft.localVisualRef,
                domainTags: normalizedTags,
                styleParams: draft.styleParams,
                createdAt: now,
                updatedAt: now,
                favorite: draft.favorite
            )
            records.insert(saved, at: 0)
        }
        try persist()
        return saved
    }

    public func delete(_ record: RainGlyphScoreRecord) throws {
        records.removeAll { $0.id == record.id }
        try persist()
    }

    public func toggleFavorite(_ record: RainGlyphScoreRecord) throws {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index].favorite.toggle()
        records[index].updatedAt = Date()
        try persist()
    }

    public func record(withID id: UUID) -> RainGlyphScoreRecord? {
        records.first { $0.id == id }
    }

    public func reloadForReadback() {
        load()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            records = try decoder.decode([RainGlyphScoreRecord].self, from: data)
                .sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            records = []
        }
    }

    private func persist() throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let data = try encoder.encode(records)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func normalizedTags(from draft: RainGlyphDraft) -> [String] {
        let explicit = draft.domainTags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if !explicit.isEmpty { return Array(Set(explicit)).sorted() }
        return draft.tapFeeling
            .split { $0 == " " || $0 == "," || $0 == "." || $0 == "\n" || $0 == "\t" }
            .map { $0.lowercased() }
            .prefix(5)
            .map(String.init)
    }

    private static func defaultStoreURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("RainGlyphComposer", isDirectory: true)
            .appendingPathComponent("rain-glyph-scores.json")
    }

    private static func loadStarterExamples() -> [StarterExample] {
        guard let url = Bundle.module.url(forResource: "StarterExamples", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let examples = try? JSONDecoder().decode([StarterExample].self, from: data) else {
            return [
                StarterExample(
                    id: "local-starter",
                    title: "Local Starter Rain Score",
                    localAssetName: "rain.local.starter",
                    disclosureCopy: "Local starter example only. Create your own rain glyph score to save personal rain-tap details."
                )
            ]
        }
        return examples
    }
}
