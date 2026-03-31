import Foundation
import SwiftUI

public extension LangCat {

    /// Fetches the live LangCat translation for a specified `LocalizedStringResource`.
    ///
    /// - Important: Because this parameter is typed as a `LocalizedStringResource`, Xcode 15+
    /// will automatically extract any string literals passed to this function directly into your `Localizable.xcstrings` file upon build.
    ///
    /// - Note: Unlike `LCText`, this method resolves synchronously and does not reactively redraw views
    /// when `.localizationsUpdatedNotification` fires. It is designed for ViewModels, Alerts, and non-UI logic.
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    static func localize(_ resource: LocalizedStringResource) -> String {
        return LangCat.shared.localizedString(forKey: resource.key)
    }

    /// Fetches the live LangCat translation for a specified `LocalizedStringKey`.
    ///
    /// This initializer is disfavored so the compiler properly defaults string literals
    /// to the `LocalizedStringResource` signature, ensuring automatic Xcode extraction.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @_disfavoredOverload
    static func localize(_ key: LocalizedStringKey) -> String {
        return LangCat.shared.localizedString(forKey: key.stringKey)
    }

    /// Fetches the live LangCat translation for a specified `StringProtocol` key.
    ///
    /// This initializer is disfavored so the compiler properly defaults string literals
    /// to the `LocalizedStringResource` signature, ensuring automatic Xcode extraction.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @_disfavoredOverload
    static func localize<S>(_ key: S) -> String where S : StringProtocol {
        return LangCat.shared.localizedString(forKey: String(key))
    }
}
