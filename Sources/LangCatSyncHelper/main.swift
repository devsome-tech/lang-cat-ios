import Foundation
import CryptoKit

// MARK: - Sentinel Helper
// The sentinel file is declared as the output of the SPM buildCommand.
// It MUST be written on every non-fatal exit so Xcode knows the command succeeded.

func writeSentinelAndExit(_ code: Int32 = 0) -> Never {
    if let sentinelPath = ProcessInfo.processInfo.environment["LANGCAT_SENTINEL_FILE"] {
        try? "ok".write(toFile: sentinelPath, atomically: true, encoding: .utf8)
    }
    exit(code)
}

// MARK: - Config Plist Loader
// SPM plugin prevents scheme env vars from reaching the helper.
// Read the API key from LangCat-Info.plist in SRCROOT instead.
// Format: standard Apple Property List (dictionary)

func loadPlistConfig(from directory: String) -> [String: String] {
    let root = URL(fileURLWithPath: directory)

    // Search locations: SRCROOT itself, then each immediate subdirectory
    var candidates = [root.appendingPathComponent("LangCat-Info.plist")]
    if let subs = try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey]) {
        for sub in subs {
            let isDir = (try? sub.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDir {
                candidates.append(sub.appendingPathComponent("LangCat-Info.plist"))
            }
        }
    }

    for candidate in candidates {
        guard let data = try? Data(contentsOf: candidate),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] else {
            continue
        }
        return plist
    }
    return [:]
}

// MARK: - Configuration

let projectDir = ProcessInfo.processInfo.environment["SRCROOT"]
    ?? FileManager.default.currentDirectoryPath

// Prefer env var (useful in CI), then fall back to LangCat-Info.plist
let configFile = loadPlistConfig(from: projectDir)

let apiKey: String = {
    if let key = ProcessInfo.processInfo.environment["LANGCAT_API_KEY"], !key.isEmpty { return key }
    if let key = configFile["LANGCAT_API_KEY"], !key.isEmpty { return key }
    return ""
}()

guard !apiKey.isEmpty else {
    let expectedPath = URL(fileURLWithPath: projectDir).appendingPathComponent("LangCat-Info.plist").path
    print("⚠️  LangCat: LANGCAT_API_KEY not set. Skipping sync.")
    print("   Looking for: \(expectedPath)")
    print("   → Download LangCat-Info.plist from your LangCat dashboard and place it there.")
    writeSentinelAndExit(0)
}

let apiUrl = configFile["LANGCAT_API_URL"]
    ?? ProcessInfo.processInfo.environment["LANGCAT_API_URL"]
    ?? "https://api.langcat.dev/api/sync"

let appVersion = ProcessInfo.processInfo.environment["MARKETING_VERSION"] ?? "1.0"

// MARK: - Find .xcstrings

func findXcstrings(in directory: String) -> URL? {
    let dirURL = URL(fileURLWithPath: directory)
    guard let enumerator = FileManager.default.enumerator(at: dirURL, includingPropertiesForKeys: nil) else {
        return nil
    }
    for case let fileURL as URL in enumerator where fileURL.pathExtension == "xcstrings" {
        return fileURL
    }
    return nil
}

guard let xcstringsURL = findXcstrings(in: projectDir) else {
    print("⚠️  LangCat: No .xcstrings file found in \(projectDir). Skipping sync.")
    writeSentinelAndExit(0)
}

// MARK: - Hash Checking

func sha256(_ data: Data) -> String {
    SHA256.hash(data: data)
        .compactMap { String(format: "%02x", $0) }
        .joined()
}

let cacheFileURL = URL(fileURLWithPath: projectDir).appendingPathComponent(".langcat_cache")

do {
    let fileData = try Data(contentsOf: xcstringsURL)
    let currentHash = sha256(fileData)

    // Skip upload if unchanged
    if FileManager.default.fileExists(atPath: cacheFileURL.path),
       let previousHash = try? String(contentsOf: cacheFileURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines),
       currentHash == previousHash {
        print("LangCat: No changes detected. Skipping upload.")
        writeSentinelAndExit(0)
    }

    print("LangCat: Uploading \(xcstringsURL.lastPathComponent) (v\(appVersion))...")

    // MARK: - Multipart Upload

    var request = URLRequest(url: URL(string: apiUrl)!)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    let boundary = "LangCat-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    func appendField(_ name: String, value: String) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(value)\r\n".data(using: .utf8)!)
    }

    appendField("version", value: appVersion)

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(xcstringsURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    request.httpBody = body

    // MARK: - Send (synchronous via semaphore — safe in a build tool)

    let semaphore = DispatchSemaphore(value: 0)

    URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }

        if let error = error {
            print("LangCat: Network error — \(error.localizedDescription)")
            return
        }

        guard let http = response as? HTTPURLResponse else { return }

        if http.statusCode == 200 {
            try? currentHash.write(to: cacheFileURL, atomically: true, encoding: .utf8)
            print("LangCat: Sync complete.")
        } else {
            let body = String(data: data ?? Data(), encoding: .utf8) ?? ""
            print("LangCat: Server returned \(http.statusCode). \(body)")
        }
    }.resume()

    semaphore.wait()

    // Always write sentinel after network attempt (success or soft failure)
    writeSentinelAndExit(0)

} catch {
    print("LangCat: File error — \(error.localizedDescription)")
    exit(1) // Hard failure — DON'T write sentinel; let the build fail
}
