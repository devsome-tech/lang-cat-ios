import SwiftUI

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, macOS 13.0, *)
public struct LCText: View {
    private let builder: () -> Text
    
    @State private var refreshID = UUID()

    public init(_ builder: @escaping () -> Text) {
        self.builder = builder
    }

    public var body: some View {
        builder()
            .id(refreshID)
            .onReceive(NotificationCenter.default.publisher(for: LangCat.localizationsUpdatedNotification)) { _ in
                refreshID = UUID()
            }
    }
}

// MARK: - Localized String Key & Resource (LangCat)
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, macOS 13.0, *)
public extension LCText {
    init(_ resource: LocalizedStringResource) {
        self.init { Text(LangCat.shared.localizedString(forKey: resource.key)) }
    }

    @_disfavoredOverload
    init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
        self.init { Text(LangCat.shared.localizedString(forKey: key.stringKey)) }
    }

    @_disfavoredOverload
    init<S>(_ content: S) where S : StringProtocol {
        self.init { Text(LangCat.shared.localizedString(forKey: String(content))) }
    }

    init(verbatim content: String) {
        self.init { Text(verbatim: content) }
    }
}
