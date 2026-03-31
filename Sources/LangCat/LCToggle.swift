import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LCToggle<Label: View>: View {
    private let builder: () -> Toggle<Label>
    
    @State private var refreshID = UUID()

    init(_ builder: @escaping () -> Toggle<Label>) {
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

// MARK: - Text Labels (isOn)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCToggle where Label == Text {

    init(_ titleResource: LocalizedStringResource, isOn: Binding<Bool>) {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleResource.key), isOn: isOn) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleKey.stringKey), isOn: isOn) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, isOn: Binding<Bool>) where S : StringProtocol {
        self.init { Toggle(LangCat.shared.localizedString(forKey: String(title)), isOn: isOn) }
    }
}

// MARK: - Text Labels (Sources)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCToggle where Label == Text {

    init<C>(_ titleResource: LocalizedStringResource, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleResource.key), sources: sources, isOn: isOn) }
    }

    @_disfavoredOverload
    init<C>(_ titleKey: LocalizedStringKey, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleKey.stringKey), sources: sources, isOn: isOn) }
    }

    @_disfavoredOverload
    init<S, C>(_ title: S, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where S : StringProtocol, C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: String(title)), sources: sources, isOn: isOn) }
    }
}

// MARK: - Label<Text, Image> (System Image)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCToggle where Label == SwiftUI.Label<Text, Image> {

    init(_ titleResource: LocalizedStringResource, systemImage: String, isOn: Binding<Bool>) {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleResource.key), systemImage: systemImage, isOn: isOn) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, systemImage: String, isOn: Binding<Bool>) {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleKey.stringKey), systemImage: systemImage, isOn: isOn) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, systemImage: String, isOn: Binding<Bool>) where S : StringProtocol {
        self.init { Toggle(LangCat.shared.localizedString(forKey: String(title)), systemImage: systemImage, isOn: isOn) }
    }

    init<C>(_ titleResource: LocalizedStringResource, systemImage: String, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleResource.key), systemImage: systemImage, sources: sources, isOn: isOn) }
    }

    @_disfavoredOverload
    init<C>(_ titleKey: LocalizedStringKey, systemImage: String, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleKey.stringKey), systemImage: systemImage, sources: sources, isOn: isOn) }
    }

    @_disfavoredOverload
    init<S, C>(_ title: S, systemImage: String, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where S : StringProtocol, C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: String(title)), systemImage: systemImage, sources: sources, isOn: isOn) }
    }
}

// MARK: - Label<Text, Image> (Image Resource)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension LCToggle where Label == SwiftUI.Label<Text, Image> {

    init(_ titleResource: LocalizedStringResource, image: ImageResource, isOn: Binding<Bool>) {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleResource.key), image: image, isOn: isOn) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, image: ImageResource, isOn: Binding<Bool>) {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleKey.stringKey), image: image, isOn: isOn) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, image: ImageResource, isOn: Binding<Bool>) where S : StringProtocol {
        self.init { Toggle(LangCat.shared.localizedString(forKey: String(title)), image: image, isOn: isOn) }
    }

    init<C>(_ titleResource: LocalizedStringResource, image: ImageResource, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleResource.key), image: image, sources: sources, isOn: isOn) }
    }

    @_disfavoredOverload
    init<C>(_ titleKey: LocalizedStringKey, image: ImageResource, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: titleKey.stringKey), image: image, sources: sources, isOn: isOn) }
    }

    @_disfavoredOverload
    init<S, C>(_ title: S, image: ImageResource, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where S : StringProtocol, C : RandomAccessCollection {
        self.init { Toggle(LangCat.shared.localizedString(forKey: String(title)), image: image, sources: sources, isOn: isOn) }
    }
}
