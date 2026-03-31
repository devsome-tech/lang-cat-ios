import Foundation

extension Bundle {
    nonisolated(unsafe) private static var isSwizzled = false
    
    static func swizzleLocalization() {
        guard !isSwizzled else { return }
        isSwizzled = true
        
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let swizzledSelector = #selector(Bundle.langcat_localizedString(forKey:value:table:))
        
        guard let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector) else {
            print("LangCat: Failed to swizzle Bundle.localizedString")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)

        print("LangCat: Bundle.localizedString swizzled successfully.")
    }
    
    @objc func langcat_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let table = tableName, table != "Localizable" {
            return originalLocalizedString(forKey: key, value: value, table: tableName)
        }
        
        return LangCat.shared.localizedString(forKey: key, value: value, table: tableName, bundle: self)
    }
    
    func originalLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return langcat_localizedString(forKey: key, value: value, table: tableName)
    }
}
