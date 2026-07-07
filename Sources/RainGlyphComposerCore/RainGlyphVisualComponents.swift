import SwiftUI

public struct RainGlyphPalette {
    public static let ink = Color(red: 0.10, green: 0.14, blue: 0.16)
    public static let mist = Color(red: 0.86, green: 0.91, blue: 0.89)
    public static let moss = Color(red: 0.43, green: 0.56, blue: 0.45)
    public static let brass = Color(red: 0.78, green: 0.65, blue: 0.42)
    public static let cloud = Color(red: 0.96, green: 0.96, blue: 0.92)
}

public struct RainWindowHero: View {
    public let style: RainGlyphStyleParams
    public let title: String

    public init(style: RainGlyphStyleParams, title: String) {
        self.style = style
        self.title = title
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [RainGlyphPalette.ink, RainGlyphPalette.moss.opacity(0.82), RainGlyphPalette.cloud.opacity(0.68)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            rainStreaks
            VStack(alignment: .leading, spacing: 8) {
                Text("Rain Window")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.76))
                Text(title.isEmpty ? "Untitled Rain Glyph" : title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("A local visual score made from your rain-tap feeling.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.78))
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, minHeight: 210)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rain window hero for a rain glyph score named \(title.isEmpty ? "Untitled Rain Glyph" : title)")
    }

    private var rainStreaks: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let count = 14
                for index in 0..<count {
                    let x = size.width * CGFloat(index + 1) / CGFloat(count + 1)
                    let height = size.height * CGFloat(0.22 + style.shimmer * 0.34)
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: size.height * 0.12 + CGFloat(index % 4) * 11))
                    path.addLine(to: CGPoint(x: x - 18, y: min(size.height - 18, height + CGFloat(index % 5) * 22)))
                    context.stroke(path, with: .color(.white.opacity(0.28)), lineWidth: CGFloat(1.2 + style.density * 2.8))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

public struct DensityBeadRow: View {
    public let density: Double
    public let selectedPalette: String

    public init(density: Double, selectedPalette: String) {
        self.density = density
        self.selectedPalette = selectedPalette
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Density Beads")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(0..<9, id: \.self) { index in
                    let isFilled = Double(index) / 8.0 <= density
                    Circle()
                        .fill(isFilled ? RainGlyphPalette.moss : RainGlyphPalette.mist)
                        .frame(width: CGFloat(12 + index), height: CGFloat(12 + index))
                        .overlay(Circle().stroke(RainGlyphPalette.ink.opacity(0.14), lineWidth: 1))
                }
            }
            Text("\(selectedPalette) · \(Int(density * 100))% rain density")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Density beads showing \(Int(density * 100)) percent rain density for this rain glyph score")
    }
}

public struct GlyphStaffPreview: View {
    public let style: RainGlyphStyleParams
    public let tags: [String]

    public init(style: RainGlyphStyleParams, tags: [String]) {
        self.style = style
        self.tags = tags
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Glyph Staff")
                .font(.headline)
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(RainGlyphPalette.cloud)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(RainGlyphPalette.ink.opacity(0.08)))
                VStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        Capsule()
                            .fill(RainGlyphPalette.ink.opacity(0.12))
                            .frame(height: 2)
                    }
                }
                HStack(alignment: .bottom, spacing: 18) {
                    ForEach(Array(tags.prefix(6).enumerated()), id: \.offset) { index, tag in
                        VStack(spacing: 4) {
                            Text(symbol(for: index))
                                .font(.system(size: CGFloat(23 + style.tempo * 11), weight: .semibold, design: .rounded))
                                .foregroundStyle(index.isMultiple(of: 2) ? RainGlyphPalette.moss : RainGlyphPalette.brass)
                            Text(tag)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
            .frame(minHeight: 136)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Glyph staff preview for rain glyph score tags \(tags.joined(separator: ", "))")
    }

    private func symbol(for index: Int) -> String {
        ["⌁", "◖", "⋮", "◠", "•", "⌒"][index % 6]
    }
}

public struct PillTag: View {
    public let title: String
    public let isSelected: Bool

    public init(title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }

    public var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? RainGlyphPalette.ink : RainGlyphPalette.mist, in: Capsule())
            .foregroundStyle(isSelected ? .white : RainGlyphPalette.ink)
            .accessibilityLabel("\(title) tag \(isSelected ? "selected" : "not selected")")
    }
}
