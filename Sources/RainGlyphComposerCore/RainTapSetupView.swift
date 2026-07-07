import SwiftUI

public struct RainTapSetupView: View {
    let onContinue: (RainGlyphDraft) -> Void

    @State private var title = ""
    @State private var tapFeeling = "soft taps on the kitchen window"
    @State private var selectedTags: Set<String> = ["window", "quiet"]
    @State private var intensity = 0.48
    @State private var usedSuggestion = false
    @FocusState private var focusedField: Field?

    private enum Field { case title, feeling }
    private let tagOptions = ["window", "roof", "quiet", "drum", "night", "garden", "brass", "moss"]

    public init(onContinue: @escaping (RainGlyphDraft) -> Void) {
        self.onContinue = onContinue
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                RainWindowHero(style: currentStyle, title: title.isEmpty ? "New Rain Glyph" : title)
                setupCopy
                inputFields
                tagPicker
                DensityBeadRow(density: intensity, selectedPalette: "Moss Beads")
                GlyphStaffPreview(style: currentStyle, tags: Array(selectedTags).sorted())
                continueButton
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(RainGlyphPalette.cloud.ignoresSafeArea())
        .navigationTitle("Rain Tap Setup")
        .toolbar { ToolbarItem(placement: .keyboard) { Button("Done") { focusedField = nil } } }
    }

    private var currentStyle: RainGlyphStyleParams {
        RainGlyphStyleParams(density: intensity, tempo: usedSuggestion ? 0.58 : 0.38, shimmer: tapFeeling.contains("window") ? 0.68 : 0.42)
    }

    private var setupCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Capture a short rain-tap feeling")
                .font(.title2.bold())
            Text("Manual input is always available. The system-assisted draft button only reshapes your local words into editable score fields.")
                .foregroundStyle(.secondary)
            Button("Suggest from rain taps", systemImage: "wand.and.rays") {
                applySuggestion()
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Suggest editable rain glyph score fields from local rain tap text")
        }
    }

    private var inputFields: some View {
        VStack(spacing: 14) {
            TextField("Score title", text: $title)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit { focusedField = .feeling }
                .accessibilityLabel("Rain glyph score title")
            TextField("Rain-tap feeling", text: $tapFeeling, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .feeling)
                .accessibilityLabel("Rain tap feeling")
            Slider(value: $intensity, in: 0.1...0.95) {
                Text("Rain density")
            }
            .accessibilityLabel("Rain density")
        }
    }

    private var tagPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Domain tags")
                .font(.headline)
            FlexibleTagGrid(tags: tagOptions) { tag in
                Button { toggle(tag) } label: {
                    PillTag(title: tag, isSelected: selectedTags.contains(tag))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var continueButton: some View {
        Button(action: continueToComposer) {
            Label("Continue to Glyph Staff Composer", systemImage: "music.quarternote.3")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .accessibilityLabel("Continue to Glyph Staff Composer with editable rain glyph score draft")
    }

    private func applySuggestion() {
        let draft = RainGlyphDraftParser.draft(from: tapFeeling)
        title = title.isEmpty ? draft.title : title
        selectedTags.formUnion(draft.domainTags)
        intensity = draft.styleParams.density
        usedSuggestion = true
    }

    private func toggle(_ tag: String) {
        if selectedTags.contains(tag) { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
    }

    private func continueToComposer() {
        onContinue(
            RainGlyphDraft(
                title: title,
                tapFeeling: tapFeeling,
                domainTags: Array(selectedTags).sorted(),
                styleParams: currentStyle,
                localVisualRef: usedSuggestion ? "system-assisted-rain-tap" : "manual-rain-tap"
            )
        )
    }
}

public struct FlexibleTagGrid<Content: View>: View {
    let tags: [String]
    let content: (String) -> Content

    public init(tags: [String], @ViewBuilder content: @escaping (String) -> Content) {
        self.tags = tags
        self.content = content
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 86), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in content(tag) }
        }
    }
}
