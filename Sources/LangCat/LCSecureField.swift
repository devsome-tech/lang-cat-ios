import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LCSecureField<Label: View>: View {
    private let builder: () -> SecureField<Label>
    
    @State private var refreshID = UUID()

    init(_ builder: @escaping () -> SecureField<Label>) {
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

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCSecureField where Label == Text {
    
    init(_ titleResource: LocalizedStringResource, text: Binding<String>, prompt: Text? = nil) {
        self.init { SecureField(LangCat.shared.localizedString(forKey: titleResource.key), text: text, prompt: prompt) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, text: Binding<String>, prompt: Text? = nil) {
        self.init { SecureField(LangCat.shared.localizedString(forKey: titleKey.stringKey), text: text, prompt: prompt) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, text: Binding<String>, prompt: Text? = nil) where S : StringProtocol {
        self.init { SecureField(LangCat.shared.localizedString(forKey: String(title)), text: text, prompt: prompt) }
    }
}
