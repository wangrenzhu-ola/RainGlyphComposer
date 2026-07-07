import Foundation
import Combine
#if canImport(AppIntents)
import AppIntents
#endif

@MainActor
public final class RainGlyphAppIntentMailbox: ObservableObject {
    public static let shared = RainGlyphAppIntentMailbox()
    @Published public var pendingDraftPrompt: String?

    private init() {}

    public func clear() {
        pendingDraftPrompt = nil
    }
}

#if canImport(AppIntents)
@available(iOS 16.0, macOS 13.0, *)
public struct DraftRainGlyphScoreIntent: AppIntent {
    public static let title: LocalizedStringResource = "Draft Rain Glyph Score"
    public static let description = IntentDescription("Open RainGlyph Composer with an editable draft from a short rain-tap note.")
    public static let openAppWhenRun = true

    @Parameter(title: "Rain taps", inputConnectionBehavior: .connectToPreviousIntentResult)
    public var rainTaps: String?

    public init() {}

    public init(rainTaps: String?) {
        self.rainTaps = rainTaps
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let prompt = (rainTaps ?? "quiet window rain").trimmingCharacters(in: .whitespacesAndNewlines)
        await MainActor.run {
            RainGlyphAppIntentMailbox.shared.pendingDraftPrompt = prompt.isEmpty ? "quiet window rain" : prompt
        }
        return .result(dialog: "Opened an editable rain glyph score draft.")
    }
}

@available(iOS 16.0, macOS 13.0, *)
public struct RainGlyphComposerShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DraftRainGlyphScoreIntent(),
            phrases: [
                "Draft a rain glyph score with \(.applicationName)",
                "Capture rain taps in \(.applicationName)"
            ],
            shortTitle: "Draft Rain Glyph",
            systemImageName: "cloud.rain"
        )
    }
}
#endif
