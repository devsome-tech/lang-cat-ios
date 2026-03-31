import SwiftUI

public extension LocalizedStringKey {
    
    /// Extracts the raw string value from SwiftUI's opaque `LocalizedStringKey` using reflection.
    /// This is necessary because SwiftUI does not expose the underlying key string publicly,
    /// and LangCat requires the raw string to look up OTA translations in the dictionary.
    var stringKey: String {
        let mirror = Mirror(reflecting: self)
        let child = mirror.children.first { $0.label == "key" }
        return (child?.value as? String) ?? ""
    }
}
