import Foundation

public class LangCat: @unchecked Sendable {
    public static let shared = LangCat()
    public static let localizationsUpdatedNotification = Notification.Name("LangCatLocalizationsUpdated")
    
    private var _apiKey: String = ""
    private var _isInitialized = false
    
    private var memoryCache: [String: [String: String]] = [:]
    private let queue = DispatchQueue(label: "com.langcat.cacheQueue", attributes: .concurrent)
    
    private var baseURL: String {
        guard let url = Bundle.main.url(forResource: "LangCat-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let explicitURL = plist["LANGCAT_API_URL"], !explicitURL.isEmpty else {
            return "https://api.langcat.dev/api/translations"
        }
        return explicitURL
    }
    
    // MARK: - Initialization
    
    /// Reads configuration from `LangCat-Info.plist` bundled in the app.
    /// Add the plist (downloaded from your LangCat dashboard) to your Xcode target's Build Phases → Copy Bundle Resources.
    public static func initialize(swizzle: Bool = true) {
        guard let url = Bundle.main.url(forResource: "LangCat-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let apiKey = plist["LANGCAT_API_KEY"], !apiKey.isEmpty else {
            print("⚠️ LangCat: LangCat-Info.plist not found or missing LANGCAT_API_KEY. Call LangCat.initialize(apiKey:) explicitly, or add LangCat-Info.plist to your app target.")
            return
        }
        initialize(apiKey: apiKey, swizzle: swizzle)
    }

    /// Explicit initialization with a hardcoded API key (Background Fetch).
    public static func initialize(apiKey: String, swizzle: Bool = true) {
        shared.queue.async(flags: .barrier) {
            shared._apiKey = apiKey
            shared._isInitialized = true
        }
        
        // Swizzle Bundle.localizedString
        if swizzle {
            Bundle.swizzleLocalization()
        }
        
        // Load existing disk cache into memory
        shared.loadDiskCache()
        
        // Fetch updates from network in the background
        shared.fetchUpdates()
    }

    // MARK: - Async Initialization
    
    /// Reads configuration from `LangCat-Info.plist` bundled in the app and reliably blocks execution until OTA string sync completely finishes.
    @available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
    public static func initializeAsync(swizzle: Bool = true) async throws {
        guard let url = Bundle.main.url(forResource: "LangCat-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let apiKey = plist["LANGCAT_API_KEY"], !apiKey.isEmpty else {
            print("⚠️ LangCat: LangCat-Info.plist not found or missing LANGCAT_API_KEY. Call LangCat.initializeAsync(apiKey:) explicitly.")
            return
        }
        try await initializeAsync(apiKey: apiKey, swizzle: swizzle)
    }

    /// Explicit initialization with an API key, blocking execution until the OTA string sync completely finishes over the network.
    @available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
    public static func initializeAsync(apiKey: String, swizzle: Bool = true) async throws {
        shared.queue.async(flags: .barrier) {
            shared._apiKey = apiKey
            shared._isInitialized = true
        }
        
        if swizzle {
            Bundle.swizzleLocalization()
        }
        
        shared.loadDiskCache()
        
        // Fetch updates synchronously over network
        try await shared.fetchUpdatesAsync()
    }
    
    // MARK: - Translation Retrieval
    public func localizedString(forKey key: String, value: String?, table tableName: String?, bundle: Bundle) -> String {
        let isInit = queue.sync { _isInitialized }

        guard isInit else {
            return bundle.originalLocalizedString(forKey: key, value: value, table: tableName)
        }
        
        if let table = tableName, table != "Localizable" {
             return bundle.originalLocalizedString(forKey: key, value: value, table: tableName)
        }
        
        let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let languagePrefix = String(preferredLanguage.prefix(2))
        
        var cachedString: String?
        queue.sync {
            if let exactMatch = memoryCache[preferredLanguage]?[key], !exactMatch.isEmpty {
                cachedString = exactMatch
            } 
            else if let prefixMatch = memoryCache[languagePrefix]?[key], !prefixMatch.isEmpty {
                cachedString = prefixMatch
            }
        }
        
        if let cached = cachedString {
            return cached
        }
        
        return bundle.originalLocalizedString(forKey: key, value: value, table: tableName)
    }

    public func localizedString(forKey key: String) -> String {
        let isInit = queue.sync { _isInitialized }

        guard isInit else {
            return key
        }
        
        let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let languagePrefix = String(preferredLanguage.prefix(2))
        
        var cachedString: String?
        queue.sync {
            if let exactMatch = memoryCache[preferredLanguage]?[key], !exactMatch.isEmpty {
                cachedString = exactMatch
            } 
            else if let prefixMatch = memoryCache[languagePrefix]?[key], !prefixMatch.isEmpty {
                cachedString = prefixMatch
            }
        }
        
        if let cached = cachedString {
            return cached
        }
        
        return key
    }
    
    private func fetchUpdates() {
        let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let languagePrefix = String(preferredLanguage.prefix(2))
        
        guard var components = URLComponents(string: baseURL) else { return }
        components.queryItems = [URLQueryItem(name: "lang", value: preferredLanguage)]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let key = queue.sync { _apiKey }
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("LangCat: Network fetch failed.", error?.localizedDescription ?? "")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("LangCat: Server returned status code \(httpResponse.statusCode)")
                return
            }

            do {
                if let translations = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    self.queue.async(flags: .barrier) {
                        self.memoryCache[preferredLanguage] = translations
                        if preferredLanguage != languagePrefix {
                            self.memoryCache[languagePrefix] = translations
                        }
                    }
                    self.saveToDiskCache()
                    print("LangCat: Successfully fetched and cached \(preferredLanguage) translations over-the-air.")
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: LangCat.localizationsUpdatedNotification, object: nil)
                    }
                } else {
                    let body = String(data: data, encoding: .utf8) ?? "Unreadable"
                    print("LangCat: Received unexpected JSON structure. Body start: \(String(body.prefix(100)))")
                }
            } catch {
                let body = String(data: data, encoding: .utf8) ?? "Unreadable"
                print("LangCat: Failed to parse translation JSON: \(error.localizedDescription). Body start: \(String(body.prefix(100)))")
            }
        }
        task.resume()
    }

    @available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
    private func fetchUpdatesAsync() async throws {
        let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let languagePrefix = String(preferredLanguage.prefix(2))
        
        guard var components = URLComponents(string: baseURL) else { return }
        components.queryItems = [URLQueryItem(name: "lang", value: preferredLanguage)]
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let key = queue.sync { _apiKey }
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("LangCat: Server returned status code \(httpResponse.statusCode)")
            return
        }
        
        do {
            if let translations = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                self.queue.async(flags: .barrier) {
                    self.memoryCache[preferredLanguage] = translations
                    if preferredLanguage != languagePrefix {
                        self.memoryCache[languagePrefix] = translations
                    }
                }
                self.saveToDiskCache()
                print("LangCat: Successfully fetched and cached \(preferredLanguage) translations synchronously over-the-air.")
                
                await MainActor.run {
                    NotificationCenter.default.post(name: LangCat.localizationsUpdatedNotification, object: nil)
                }
            } else {
                let body = String(data: data, encoding: .utf8) ?? "Unreadable"
                print("LangCat: Received unexpected JSON structure. Body start: \(String(body.prefix(100)))")
            }
        } catch {
            let body = String(data: data, encoding: .utf8) ?? "Unreadable"
            print("LangCat: Failed to parse translation JSON: \(error.localizedDescription). Body start: \(String(body.prefix(100)))")
        }
    }
    
    private func getCacheFileURL() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("LangCatCache.json")
    }
    
    private func saveToDiskCache() {
        let fileURL = getCacheFileURL()
        queue.sync {
            do {
                let data = try JSONSerialization.data(withJSONObject: memoryCache, options: [])
                try data.write(to: fileURL)
            } catch {
                print("LangCat: Failed to write cache to disk: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadDiskCache() {
        let fileURL = getCacheFileURL()
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: String]] {
                queue.async(flags: .barrier) {
                    self.memoryCache = json
                    print("LangCat: Loaded \(json.keys.count) languages from disk cache.")
                }
            }
        } catch {
            print("LangCat: Failed to load cache from disk: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
