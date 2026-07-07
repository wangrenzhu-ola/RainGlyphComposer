import Foundation

public struct RainGlyphStyleParams: Codable, Equatable, Hashable, Sendable {
    public var density: Double
    public var tempo: Double
    public var shimmer: Double
    public var windowTone: String
    public var beadPalette: String

    public init(
        density: Double = 0.48,
        tempo: Double = 0.42,
        shimmer: Double = 0.36,
        windowTone: String = "Slate Rain",
        beadPalette: String = "Moss Beads"
    ) {
        self.density = density
        self.tempo = tempo
        self.shimmer = shimmer
        self.windowTone = windowTone
        self.beadPalette = beadPalette
    }
}

public struct RainGlyphScoreRecord: Codable, Identifiable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var title: String
    public var localVisualRef: String
    public var domainTags: [String]
    public var styleParams: RainGlyphStyleParams
    public var createdAt: Date
    public var updatedAt: Date
    public var favorite: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        localVisualRef: String,
        domainTags: [String],
        styleParams: RainGlyphStyleParams,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        favorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.localVisualRef = localVisualRef
        self.domainTags = domainTags
        self.styleParams = styleParams
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.favorite = favorite
    }
}

public struct StarterExample: Codable, Identifiable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var localAssetName: String
    public var disclosureCopy: String

    public init(id: String, title: String, localAssetName: String, disclosureCopy: String) {
        self.id = id
        self.title = title
        self.localAssetName = localAssetName
        self.disclosureCopy = disclosureCopy
    }
}

public struct RainGlyphDraft: Equatable, Hashable, Sendable {
    public var id: UUID?
    public var title: String
    public var tapFeeling: String
    public var domainTags: [String]
    public var styleParams: RainGlyphStyleParams
    public var localVisualRef: String
    public var favorite: Bool

    public init(
        id: UUID? = nil,
        title: String = "",
        tapFeeling: String = "",
        domainTags: [String] = [],
        styleParams: RainGlyphStyleParams = RainGlyphStyleParams(),
        localVisualRef: String = "rain-window-handmade",
        favorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.tapFeeling = tapFeeling
        self.domainTags = domainTags
        self.styleParams = styleParams
        self.localVisualRef = localVisualRef
        self.favorite = favorite
    }
}

public extension RainGlyphScoreRecord {
    var draftForEditing: RainGlyphDraft {
        RainGlyphDraft(
            id: id,
            title: title,
            tapFeeling: domainTags.joined(separator: ", "),
            domainTags: domainTags,
            styleParams: styleParams,
            localVisualRef: localVisualRef,
            favorite: favorite
        )
    }
}

public enum RainGlyphDraftParser {
    public static func draft(from text: String) -> RainGlyphDraft {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = cleaned
            .split { $0 == " " || $0 == "," || $0 == "." || $0 == "\n" || $0 == "\t" }
            .map(String.init)
        let tags = Array(words.prefix(4)).map { $0.lowercased() }
        let density = min(0.95, max(0.15, Double(words.count) / 12.0))
        let tempo = cleaned.contains("fast") || cleaned.contains("drum") ? 0.72 : 0.38
        let shimmer = cleaned.contains("window") || cleaned.contains("light") ? 0.68 : 0.34
        let title = cleaned.isEmpty ? "Untitled Rain Glyph" : String(cleaned.prefix(38))
        return RainGlyphDraft(
            title: title,
            tapFeeling: cleaned,
            domainTags: tags.isEmpty ? ["quiet", "window"] : tags,
            styleParams: RainGlyphStyleParams(density: density, tempo: tempo, shimmer: shimmer),
            localVisualRef: "system-assisted-rain-tap"
        )
    }
}
