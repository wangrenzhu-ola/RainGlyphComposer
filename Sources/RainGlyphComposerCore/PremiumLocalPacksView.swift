import SwiftUI

public struct PremiumLocalPacksView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var premiumStore = PremiumStore()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    RainWindowHero(style: RainGlyphStyleParams(density: 0.72, tempo: 0.58, shimmer: 0.72), title: "Premium Local Packs")
                    Text("Optional local visual packs")
                        .font(.title2.bold())
                    Text("Premium unlocks extra rain window, density bead, and glyph staff treatments. Creating, editing, saving, and deleting rain glyph scores remain free.")
                        .foregroundStyle(.secondary)
                    packList
                    statusPanel
                    purchaseButtons
                    PrivacyBoundaryCard()
                }
                .padding(20)
            }
            .background(RainGlyphPalette.cloud.ignoresSafeArea())
            .navigationTitle("Premium Local Packs")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .task { await premiumStore.loadProducts() }
        }
    }

    private var packList: some View {
        VStack(spacing: 12) {
            PremiumPackCard(title: "Moss Window", detail: "Softer window gradient and denser bead rhythm.")
            PremiumPackCard(title: "Brass Drizzle", detail: "Warm glyph staff accents for evening rain listening.")
            PremiumPackCard(title: "Cloud Glass", detail: "Low-contrast card treatment for quiet shelves.")
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(premiumStore.isPremiumUnlocked ? "Premium unlocked" : "Premium optional", systemImage: premiumStore.isPremiumUnlocked ? "checkmark.seal.fill" : "sparkles")
                .font(.headline)
            Text(premiumStore.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var purchaseButtons: some View {
        VStack(spacing: 12) {
            Button { Task { await premiumStore.purchasePremium() } } label: {
                Label("Unlock Premium Local Packs", systemImage: "cart")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button { Task { await premiumStore.restore() } } label: {
                Label("Restore Purchase", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .accessibilityLabel("Premium local packs StoreKit controls that do not block base rain glyph score creation")
    }
}

private struct PremiumPackCard: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "cloud.rain.fill")
                .font(.title2)
                .foregroundStyle(RainGlyphPalette.moss)
                .frame(width: 44, height: 44)
                .background(RainGlyphPalette.mist, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
