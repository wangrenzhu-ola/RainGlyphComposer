import SwiftUI

public struct RainGlyphScoreDetailView: View {
    @ObservedObject var store: RainGlyphStore
    let recordID: UUID
    let onEdit: (RainGlyphDraft) -> Void
    let onDeleted: () -> Void
    let onPremium: () -> Void

    @State private var showDeleteConfirmation = false
    @State private var actionMessage: String?

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if let record = store.record(withID: recordID) {
                    detailContent(record)
                } else {
                    missingRecordState
                }
            }
            .padding(20)
        }
        .background(RainGlyphPalette.cloud.ignoresSafeArea())
        .navigationTitle("Rain Glyph Score Detail")
    }

    private func detailContent(_ record: RainGlyphScoreRecord) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            RainWindowHero(style: record.styleParams, title: record.title)
            DensityBeadRow(density: record.styleParams.density, selectedPalette: record.styleParams.beadPalette)
            GlyphStaffPreview(style: record.styleParams, tags: record.domainTags)
            tagSummary(record)
            actionButtons(record)
            if let actionMessage {
                Text(actionMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .alert("Delete \(record.title)?", isPresented: $showDeleteConfirmation) {
            Button("Delete Rain Glyph Score", role: .destructive) { delete(record) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the local rain glyph score and its glyph staff preview from your shelf.")
        }
    }

    private func tagSummary(_ record: RainGlyphScoreRecord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Score tags")
                .font(.headline)
            FlexibleTagGrid(tags: record.domainTags) { tag in
                PillTag(title: tag, isSelected: true)
            }
            Text("Updated \(record.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func actionButtons(_ record: RainGlyphScoreRecord) -> some View {
        VStack(spacing: 12) {
            Button { onEdit(record.draftForEditing) } label: {
                Label("Edit Glyph Staff", systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button { toggleFavorite(record) } label: {
                Label(record.favorite ? "Remove Favorite" : "Mark Favorite", systemImage: record.favorite ? "star.slash" : "star")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            Button(action: onPremium) {
                Label("Preview Premium Local Packs", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            Button(role: .destructive) { showDeleteConfirmation = true } label: {
                Label("Delete Rain Glyph Score", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Show delete confirmation for rain glyph score named \(record.title)")
        }
    }

    private var missingRecordState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rain glyph score unavailable")
                .font(.title2.bold())
            Text("The local score may have been deleted. Return to the shelf to continue.")
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func toggleFavorite(_ record: RainGlyphScoreRecord) {
        do {
            try store.toggleFavorite(record)
            actionMessage = record.favorite ? "Removed from favorites." : "Marked as a favorite rain glyph score."
        } catch {
            actionMessage = "Favorite update failed. Your rain glyph score is unchanged."
        }
    }

    private func delete(_ record: RainGlyphScoreRecord) {
        do {
            try store.delete(record)
            onDeleted()
        } catch {
            actionMessage = "Delete failed. The local rain glyph score is still available."
        }
    }
}
