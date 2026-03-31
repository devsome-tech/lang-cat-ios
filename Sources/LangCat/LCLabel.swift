import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LCLabel<Title: View, Icon: View>: View {
    private let builder: () -> Label<Title, Icon>
    
    @State private var refreshID = UUID()

    init(_ builder: @escaping () -> Label<Title, Icon>) {
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

// MARK: - Text / Image (System)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCLabel where Title == Text, Icon == Image {

    init(_ titleResource: LocalizedStringResource, systemImage: String) {
        self.init { Label(LangCat.shared.localizedString(forKey: titleResource.key), systemImage: systemImage) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, systemImage: String) {
        self.init { Label(LangCat.shared.localizedString(forKey: titleKey.stringKey), systemImage: systemImage) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, systemImage: String) where S : StringProtocol {
        self.init { Label(LangCat.shared.localizedString(forKey: String(title)), systemImage: systemImage) }
    }
}

// MARK: - Text / Image (Asset)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension LCLabel where Title == Text, Icon == Image {

    init(_ titleResource: LocalizedStringResource, image: ImageResource) {
        self.init { Label(LangCat.shared.localizedString(forKey: titleResource.key), image: image) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, image: ImageResource) {
        self.init { Label(LangCat.shared.localizedString(forKey: titleKey.stringKey), image: image) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, image: ImageResource) where S : StringProtocol {
        self.init { Label(LangCat.shared.localizedString(forKey: String(title)), image: image) }
    }
}
