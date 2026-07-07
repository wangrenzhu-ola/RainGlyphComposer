import SwiftUI

public struct GlyphStaffComposerView: View {
    @ObservedObject var store: RainGlyphStore
    let onSaved: (RainGlyphScoreRecord) -> Void

    @State private var draft: RainGlyphDraft
    @State private var tagText: String
    @State private var simulateSaveFailure = false
    @State private var feedback: Feedback?
    @FocusState private var focusedField: Field?

    private enum Field { case title, feeling, tags }
    private enum Feedback: Equatable { case saving, saved, failed(String) }

    public init(store: RainGlyphStore, initialDraft: RainGlyphDraft, onSaved: @escaping (RainGlyphScoreRecord) -> Void) {
        self.store = store
        self.onSaved = onSaved
        _draft = State(initialValue: initialDraft)
        _tagText = State(initialValue: initialDraft.domainTags.joined(separator: ", "))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                RainWindowHero(style: draft.styleParams, title: draft.title)
                statusBanner
                editorFields
                visualControls
                DensityBeadRow(density: draft.styleParams.density, selectedPalette: draft.styleParams.beadPalette)
                GlyphStaffPreview(style: draft.styleParams, tags: normalizedTags)
                saveControls
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(RainGlyphPalette.cloud.ignoresSafeArea())
        .navigationTitle("Glyph Staff Composer")
        .toolbar { ToolbarItem(placement: .keyboard) { Button("Done") { focusedField = nil } } }
    }

    private var normalizedTags: [String] {
        let tags = tagText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        return tags.isEmpty ? ["window", "quiet"] : tags
    }

    @ViewBuilder
    private var statusBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(statusTitle, systemImage: statusIcon)
                .font(.headline)
            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(statusColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(statusTitle + ". " + statusMessage)
    }

    private var editorFields: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Editing fields")
                .font(.title3.bold())
            TextField("Score title", text: $draft.title)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .title)
                .accessibilityLabel("Edit rain glyph score title")
            TextField("Rain-tap feeling", text: $draft.tapFeeling, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .feeling)
                .accessibilityLabel("Edit rain tap feeling")
            TextField("Tags separated by commas", text: $tagText)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .tags)
                .accessibilityLabel("Edit rain glyph score tags")
        }
    }

    private var visualControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Visual score parameters")
                .font(.title3.bold())
            SliderRow(title: "Density", value: $draft.styleParams.density, accessibilityLabel: "Adjust density beads")
            SliderRow(title: "Tempo", value: $draft.styleParams.tempo, accessibilityLabel: "Adjust glyph staff tempo")
            SliderRow(title: "Shimmer", value: $draft.styleParams.shimmer, accessibilityLabel: "Adjust rain window shimmer")
            Picker("Window tone", selection: $draft.styleParams.windowTone) {
                Text("Slate Rain").tag("Slate Rain")
                Text("Moss Window").tag("Moss Window")
                Text("Warm Brass").tag("Warm Brass")
            }
            .pickerStyle(.segmented)
            Picker("Bead palette", selection: $draft.styleParams.beadPalette) {
                Text("Moss Beads").tag("Moss Beads")
                Text("Brass Drops").tag("Brass Drops")
                Text("Cloud Glass").tag("Cloud Glass")
            }
            .pickerStyle(.segmented)
        }
    }

    private var saveControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Simulate save failure for retry testing", isOn: $simulateSaveFailure)
                .accessibilityLabel("Simulate save failure without losing draft")
            Button(action: saveDraft) {
                Label("Save Rain Glyph Score", systemImage: "tray.and.arrow.down.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Save rain glyph score")
            Button("Retry without simulated failure") {
                simulateSaveFailure = false
                saveDraft()
            }
            .buttonStyle(.bordered)
            .opacity(isFailure ? 1 : 0.55)
            .accessibilityLabel("Retry saving rain glyph score without simulated failure")
        }
    }

    private var statusTitle: String {
        switch feedback {
        case .saving: "Creating rain glyph score"
        case .saved: "Save success"
        case .failed: "Save failure"
        case .none: draft.id == nil ? "Creating rain glyph score" : "Editing rain glyph score"
        }
    }

    private var statusMessage: String {
        switch feedback {
        case .saving: "Saving local score data and visual parameters."
        case .saved: "Saved locally. The shelf and detail screen will show this rain glyph score."
        case .failed(let message): message + " Edit fields remain available for retry."
        case .none: "Tune the rain window hero, density beads, and glyph staff before saving."
        }
    }

    private var statusIcon: String { isFailure ? "exclamationmark.triangle" : "cloud.rain" }
    private var statusColor: Color { isFailure ? .orange : RainGlyphPalette.moss }
    private var isFailure: Bool { if case .failed = feedback { return true } else { return false } }

    private func saveDraft() {
        feedback = .saving
        draft.domainTags = normalizedTags
        do {
            let saved = try store.save(draft, simulateFailure: simulateSaveFailure)
            feedback = .saved
            onSaved(saved)
        } catch {
            feedback = .failed(error.localizedDescription)
        }
    }
}

private struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let accessibilityLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: 0.1...0.95)
                .accessibilityLabel(accessibilityLabel)
        }
    }
}
