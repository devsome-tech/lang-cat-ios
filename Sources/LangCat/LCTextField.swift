import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LCTextField<Label: View>: View {
    private let builder: () -> TextField<Label>
    
    @State private var refreshID = UUID()

    init(_ builder: @escaping () -> TextField<Label>) {
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

// MARK: - Basic Text Binding
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCTextField where Label == Text {

    init(_ titleResource: LocalizedStringResource, text: Binding<String>, prompt: Text? = nil) {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleResource.key), text: text, prompt: prompt) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, text: Binding<String>, prompt: Text? = nil) {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleKey.stringKey), text: text, prompt: prompt) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, text: Binding<String>, prompt: Text? = nil) where S : StringProtocol {
        self.init { TextField(LangCat.shared.localizedString(forKey: String(title)), text: text, prompt: prompt) }
    }
}

// MARK: - ParseableFormatStyle (Optional Binding)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCTextField where Label == Text {

    init<F>(_ titleResource: LocalizedStringResource, value: Binding<F.FormatInput?>, format: F, prompt: Text? = nil) where F : ParseableFormatStyle, F.FormatOutput == String {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleResource.key), value: value, format: format, prompt: prompt) }
    }

    @_disfavoredOverload
    init<F>(_ titleKey: LocalizedStringKey, value: Binding<F.FormatInput?>, format: F, prompt: Text? = nil) where F : ParseableFormatStyle, F.FormatOutput == String {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleKey.stringKey), value: value, format: format, prompt: prompt) }
    }

    @_disfavoredOverload
    init<S, F>(_ title: S, value: Binding<F.FormatInput?>, format: F, prompt: Text? = nil) where S : StringProtocol, F : ParseableFormatStyle, F.FormatOutput == String {
        self.init { TextField(LangCat.shared.localizedString(forKey: String(title)), value: value, format: format, prompt: prompt) }
    }
}

// MARK: - ParseableFormatStyle (Non-Optional Binding)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCTextField where Label == Text {

    init<F>(_ titleResource: LocalizedStringResource, value: Binding<F.FormatInput>, format: F, prompt: Text? = nil) where F : ParseableFormatStyle, F.FormatOutput == String {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleResource.key), value: value, format: format, prompt: prompt) }
    }

    @_disfavoredOverload
    init<F>(_ titleKey: LocalizedStringKey, value: Binding<F.FormatInput>, format: F, prompt: Text? = nil) where F : ParseableFormatStyle, F.FormatOutput == String {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleKey.stringKey), value: value, format: format, prompt: prompt) }
    }

    @_disfavoredOverload
    init<S, F>(_ title: S, value: Binding<F.FormatInput>, format: F, prompt: Text? = nil) where S : StringProtocol, F : ParseableFormatStyle, F.FormatOutput == String {
        self.init { TextField(LangCat.shared.localizedString(forKey: String(title)), value: value, format: format, prompt: prompt) }
    }
}

// MARK: - Legacy Formatter (Optional Binding)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCTextField where Label == Text {

    init<V>(_ titleResource: LocalizedStringResource, value: Binding<V>, formatter: Formatter, prompt: Text? = nil) {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleResource.key), value: value, formatter: formatter, prompt: prompt) }
    }

    @_disfavoredOverload
    init<V>(_ titleKey: LocalizedStringKey, value: Binding<V>, formatter: Formatter, prompt: Text? = nil) {
        self.init { TextField(LangCat.shared.localizedString(forKey: titleKey.stringKey), value: value, formatter: formatter, prompt: prompt) }
    }

    @_disfavoredOverload
    init<S, V>(_ title: S, value: Binding<V>, formatter: Formatter, prompt: Text? = nil) where S : StringProtocol {
        self.init { TextField(LangCat.shared.localizedString(forKey: String(title)), value: value, formatter: formatter, prompt: prompt) }
    }
}
