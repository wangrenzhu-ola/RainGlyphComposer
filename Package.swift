// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RainGlyphComposer",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "RainGlyphComposerCore", targets: ["RainGlyphComposerCore"])
    ],
    targets: [
        .target(
            name: "RainGlyphComposerCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "RainGlyphComposerCoreTests",
            dependencies: ["RainGlyphComposerCore"]
        )
    ]
)
