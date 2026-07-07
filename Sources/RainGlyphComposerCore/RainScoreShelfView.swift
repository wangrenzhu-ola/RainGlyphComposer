import SwiftUI

public struct RainScoreShelfView: View {
    @ObservedObject var store: RainGlyphStore
    let onCreate: () -> Void
    let onOpen: (RainGlyphScoreRecord) -> Void
    let onPremium: () -> Void

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                shelfHeader
                if store.records.isEmpty {
                    EmptyRainScoreShelfView(starterExamples: store.starterExamples, onCreate: onCreate)
                } else {
                    scoreList
                }
                PrivacyBoundaryCard()
                starterDisclosure
            }
            .padding(20)
        }
        .background(RainGlyphPalette.cloud.ignoresSafeArea())
        .navigationTitle("Rain Score Shelf")
        .toolbar {
            Button("Premium", systemImage: "sparkles", action: onPremium)
                .accessibilityLabel("Open Premium Local Packs")
            Button("New", systemImage: "plus", action: onCreate)
                .accessibilityLabel("Create a rain glyph score")
        }
    }

    private var shelfHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RainGlyph Composer")
                .font(.largeTitle.bold())
            Text("Map a short rain-tap feeling into a visual glyph score you can revisit later.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var scoreList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Saved Rain Glyph Scores")
                .font(.title3.bold())
            ForEach(store.records) { record in
                Button { onOpen(record) } label: {
                    ScoreShelfCard(record: record)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var starterDisclosure: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Starter examples")
                .font(.headline)
            ForEach(store.starterExamples) { example in
                VStack(alignment: .leading, spacing: 4) {
                    Text(example.title).font(.subheadline.weight(.semibold))
                    Text(example.disclosureCopy).font(.caption).foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct EmptyRainScoreShelfView: View {
    let starterExamples: [StarterExample]
    let onCreate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            RainWindowHero(style: RainGlyphStyleParams(), title: "Your first rain glyph score")
            DensityBeadRow(density: 0.48, selectedPalette: "Moss Beads")
            GlyphStaffPreview(style: RainGlyphStyleParams(), tags: ["window", "tap", "quiet", "ritual"])
            Text("No rain glyph scores yet")
                .font(.title3.bold())
            Text("Start with your own rain-tap words. Local starter examples stay separate and are only here to show the shape of the ritual.")
                .foregroundStyle(.secondary)
            Button(action: onCreate) {
                Label("Create Rain Glyph Score", systemImage: "cloud.rain.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Create your first rain glyph score")
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

private struct ScoreShelfCard: View {
    let record: RainGlyphScoreRecord

    var body: some View {
        HStack(spacing: 14) {
            GlyphStaffPreview(style: record.styleParams, tags: record.domainTags)
                .frame(width: 148)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(record.title)
                        .font(.headline)
                        .foregroundStyle(RainGlyphPalette.ink)
                    if record.favorite { Image(systemName: "star.fill").foregroundStyle(RainGlyphPalette.brass) }
                }
                Text(record.domainTags.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                DensityBeadRow(density: record.styleParams.density, selectedPalette: record.styleParams.beadPalette)
            }
        }
        .padding(14)
        .background(.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Open rain glyph score named \(record.title)")
    }
}

public struct PrivacyBoundaryCard: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Local Privacy Boundary", systemImage: "lock.shield")
                .font(.headline)
            Text("Your rain glyph scores are saved locally on this device. Starter examples are bundled local content, not live weather data or a cloud service.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RainGlyphPalette.mist.opacity(0.74), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Privacy note: rain glyph score data stays local and starter examples are disclosed")
    }
}
