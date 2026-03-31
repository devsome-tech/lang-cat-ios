import SwiftUI

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, macOS 13.0, *)
public struct LCButton<Label: View>: View {
    private let role: ButtonRole?
    private let action: () -> Void
    private let labelBuilder: () -> Label
    
    @State private var refreshID = UUID()

    // Intentionally keep this internal/private as the root builder because 
    // public generic builder is removed, but we still need it for the specific string extensions to compose.
    init(role: ButtonRole? = nil, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.role = role
        self.action = action
        self.labelBuilder = label
    }

    public var body: some View {
        Button(role: role, action: action) {
            labelBuilder()
        }
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: LangCat.localizationsUpdatedNotification)) { _ in
            refreshID = UUID()
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCButton where Label == Text {

    init(_ titleResource: LocalizedStringResource, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            Text(LangCat.shared.localizedString(forKey: titleResource.key))
        }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            Text(LangCat.shared.localizedString(forKey: titleKey.stringKey))
        }
    }

    @_disfavoredOverload
    init<S>(_ title: S, role: ButtonRole? = nil, action: @escaping () -> Void) where S : StringProtocol {
        self.init(role: role, action: action) {
            Text(LangCat.shared.localizedString(forKey: String(title)))
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension LCButton where Label == SwiftUI.Label<Text, Image> {

    init(_ titleResource: LocalizedStringResource, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(LangCat.shared.localizedString(forKey: titleResource.key), systemImage: systemImage)
        }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(LangCat.shared.localizedString(forKey: titleKey.stringKey), systemImage: systemImage)
        }
    }

    @_disfavoredOverload
    init<S>(_ title: S, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) where S : StringProtocol {
        self.init(role: role, action: action) {
            SwiftUI.Label(LangCat.shared.localizedString(forKey: String(title)), systemImage: systemImage)
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension LCButton where Label == SwiftUI.Label<Text, Image> {

    init(_ titleResource: LocalizedStringResource, image: ImageResource, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(LangCat.shared.localizedString(forKey: titleResource.key), image: image)
        }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, image: ImageResource, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(LangCat.shared.localizedString(forKey: titleKey.stringKey), image: image)
        }
    }

    @_disfavoredOverload
    init<S>(_ title: S, image: ImageResource, role: ButtonRole? = nil, action: @escaping () -> Void) where S : StringProtocol {
        self.init(role: role, action: action) {
            SwiftUI.Label(LangCat.shared.localizedString(forKey: String(title)), image: image)
        }
    }
}
