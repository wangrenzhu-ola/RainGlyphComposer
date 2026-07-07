import SwiftUI
import AppIntents
import RainGlyphComposerCore

@main
struct RainGlyphComposerApp: App {
    var body: some Scene {
        WindowGroup {
            RainGlyphRootView()
        }
    }
}

struct OpenRainGlyphDraftIntent: AppIntent {
    static let title: LocalizedStringResource = "Draft Rain Glyph Score"
    static let description = IntentDescription("Open RainGlyph Composer with an editable draft from a short rain-tap note.")
    static let openAppWhenRun = true

    @Parameter(title: "Rain taps", inputConnectionBehavior: .connectToPreviousIntentResult)
    var rainTaps: String?

    init() {}

    init(rainTaps: String?) {
        self.rainTaps = rainTaps
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let prompt = (rainTaps ?? "quiet window rain").trimmingCharacters(in: .whitespacesAndNewlines)
        await MainActor.run {
            RainGlyphAppIntentMailbox.shared.pendingDraftPrompt = prompt.isEmpty ? "quiet window rain" : prompt
        }
        return .result(dialog: "Opened an editable rain glyph score draft.")
    }
}

struct RainGlyphComposerAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenRainGlyphDraftIntent(),
            phrases: [
                "Draft a rain glyph score with \(.applicationName)",
                "Capture rain taps in \(.applicationName)"
            ],
            shortTitle: "Draft Rain Glyph",
            systemImageName: "cloud.rain"
        )
    }
}
