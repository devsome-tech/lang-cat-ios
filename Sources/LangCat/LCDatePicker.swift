import SwiftUI

@available(iOS 16.0, macOS 13.0, watchOS 10.0, *)
@available(tvOS, unavailable)
public struct LCDatePicker<Label: View>: View {
    private let builder: () -> DatePicker<Label>
    
    @State private var refreshID = UUID()

    init(_ builder: @escaping () -> DatePicker<Label>) {
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

// MARK: - Text Labels (LocalizedStringResource)
@available(iOS 16.0, macOS 13.0, watchOS 10.0, *)
@available(tvOS, unavailable)
public extension LCDatePicker where Label == Text {
    
    init(_ titleResource: LocalizedStringResource, selection: Binding<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleResource.key), selection: selection, displayedComponents: displayedComponents) }
    }

    init(_ titleResource: LocalizedStringResource, selection: Binding<Date>, in range: ClosedRange<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleResource.key), selection: selection, in: range, displayedComponents: displayedComponents) }
    }

    init(_ titleResource: LocalizedStringResource, selection: Binding<Date>, in range: PartialRangeFrom<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleResource.key), selection: selection, in: range, displayedComponents: displayedComponents) }
    }

    init(_ titleResource: LocalizedStringResource, selection: Binding<Date>, in range: PartialRangeThrough<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleResource.key), selection: selection, in: range, displayedComponents: displayedComponents) }
    }
}

// MARK: - Text Labels (LocalizedStringKey)
@available(iOS 16.0, macOS 13.0, watchOS 10.0, *)
@available(tvOS, unavailable)
public extension LCDatePicker where Label == Text {
    
    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, selection: Binding<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleKey.stringKey), selection: selection, displayedComponents: displayedComponents) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, selection: Binding<Date>, in range: ClosedRange<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleKey.stringKey), selection: selection, in: range, displayedComponents: displayedComponents) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, selection: Binding<Date>, in range: PartialRangeFrom<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleKey.stringKey), selection: selection, in: range, displayedComponents: displayedComponents) }
    }

    @_disfavoredOverload
    init(_ titleKey: LocalizedStringKey, selection: Binding<Date>, in range: PartialRangeThrough<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: titleKey.stringKey), selection: selection, in: range, displayedComponents: displayedComponents) }
    }
}

// MARK: - Text Labels (StringProtocol)
@available(iOS 16.0, macOS 13.0, watchOS 10.0, *)
@available(tvOS, unavailable)
public extension LCDatePicker where Label == Text {
    
    @_disfavoredOverload
    init<S>(_ title: S, selection: Binding<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) where S : StringProtocol {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: String(title)), selection: selection, displayedComponents: displayedComponents) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, selection: Binding<Date>, in range: ClosedRange<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) where S : StringProtocol {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: String(title)), selection: selection, in: range, displayedComponents: displayedComponents) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, selection: Binding<Date>, in range: PartialRangeFrom<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) where S : StringProtocol {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: String(title)), selection: selection, in: range, displayedComponents: displayedComponents) }
    }

    @_disfavoredOverload
    init<S>(_ title: S, selection: Binding<Date>, in range: PartialRangeThrough<Date>, displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]) where S : StringProtocol {
        self.init { DatePicker(LangCat.shared.localizedString(forKey: String(title)), selection: selection, in: range, displayedComponents: displayedComponents) }
    }
}
