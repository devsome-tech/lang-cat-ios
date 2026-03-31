// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "lang-cat-ios",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "LangCat",
            targets: ["LangCat"]
        ),
        .plugin(
            name: "LangCatSyncCommand",
            targets: ["LangCatSyncCommand"]
        ),
    ],
    targets: [
        .target(
            name: "LangCat",
            path: "Sources/LangCat"
        ),
        .plugin(
            name: "LangCatSyncCommand",
            capability: .command(
                intent: .custom(
                    verb: "sync-langcat",
                    description: "Uploads .xcstrings to LangCat for AI-powered translation."
                ),
                permissions: [
                    .allowNetworkConnections(
                        scope: .all(ports: [80, 443, 3000]),
                        reason: "Uploads your .xcstrings file to the LangCat localization API."
                    )
                ]
            ),
            dependencies: ["LangCatSyncHelper"]
        ),

        .executableTarget(
            name: "LangCatSyncHelper",
            path: "Sources/LangCatSyncHelper"
        ),

    ]
)
