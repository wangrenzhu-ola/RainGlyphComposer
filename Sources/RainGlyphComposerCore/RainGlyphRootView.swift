import SwiftUI

public enum RainGlyphRoute: Hashable {
    case setup
    case composer(RainGlyphDraft)
    case detail(UUID)
}

private enum RainGlyphSheet: Identifiable {
    case premium

    var id: String { "premium" }
}

public struct RainGlyphRootView: View {
    @StateObject private var store = RainGlyphStore()
    @StateObject private var intentMailbox = RainGlyphAppIntentMailbox.shared
    @State private var path: [RainGlyphRoute] = []
    @State private var activeSheet: RainGlyphSheet?

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            RainScoreShelfView(
                store: store,
                onCreate: showSetup,
                onOpen: showDetail,
                onPremium: showPremium
            )
            .navigationDestination(for: RainGlyphRoute.self, destination: destination)
            .sheet(item: $activeSheet, content: sheetContent)
            .onReceive(intentMailbox.$pendingDraftPrompt.compactMap { $0 }) { prompt in
                handleIntentPrompt(prompt)
            }
        }
        .tint(RainGlyphPalette.moss)
    }

    @ViewBuilder
    private func destination(for route: RainGlyphRoute) -> some View {
        switch route {
        case .setup:
            RainTapSetupView { draft in
                path.append(.composer(draft))
            }
        case .composer(let draft):
            GlyphStaffComposerView(store: store, initialDraft: draft) { record in
                path.removeAll()
                path.append(.detail(record.id))
            }
        case .detail(let id):
            RainGlyphScoreDetailView(
                store: store,
                recordID: id,
                onEdit: { draft in path.append(.composer(draft)) },
                onDeleted: { path.removeAll() },
                onPremium: showPremium
            )
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: RainGlyphSheet) -> some View {
        switch sheet {
        case .premium:
            PremiumLocalPacksView()
        }
    }

    private func showSetup() {
        path.append(.setup)
    }

    private func showDetail(_ record: RainGlyphScoreRecord) {
        path.append(.detail(record.id))
    }

    private func showPremium() {
        activeSheet = .premium
    }

    private func handleIntentPrompt(_ prompt: String) {
        path.removeAll()
        path.append(.composer(RainGlyphDraftParser.draft(from: prompt)))
        intentMailbox.clear()
    }
}
