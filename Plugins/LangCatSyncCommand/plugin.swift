import PackagePlugin
import Foundation

/// LangCatSyncCommand — SPM Command Plugin
/// Triggered manually in Xcode: right-click your project → "Sync with LangCat"
@main
struct LangCatSyncCommand: CommandPlugin {

    // Called when run via `swift package plugin sync-langcat` or Xcode right-click
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let helper = try context.tool(named: "LangCatSyncHelper")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: helper.path.string)
        process.environment = [
            "SRCROOT": context.package.directory.string,
        ]
        try process.run()
        process.waitUntilExit()
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension LangCatSyncCommand: XcodeCommandPlugin {

    // Called when triggered from Xcode (right-click → Sync with LangCat)
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let helper = try context.tool(named: "LangCatSyncHelper")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: helper.path.string)
        process.environment = [
            "SRCROOT": context.xcodeProject.directory.string,
        ]
        try process.run()
        process.waitUntilExit()
    }
}
#endif
