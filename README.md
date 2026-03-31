<h2 align="center">App Localization Made Instant</h2>

<p align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version"></a>
    <a href="https://github.com/lang-cat/lang-cat-ios/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
    <a href="https://api.langcat.dev"><img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgray.svg" alt="Platforms"></a>
</p>

LangCat is a remote localization and translation delivery platform for Apple apps. It allows you to manage, translate, and update your app's strings **over-the-air (OTA)** instantly—without waiting for App Store reviews.

Designed to mirror native Apple APIs, LangCat requires zero changes to your existing `Localizable.xcstrings` or `Text()` SwiftUI codebase. It just works.

### Features
**Zero-Code Integration** - Use native `Text()`, `Label()`, and `String(localized:)`. LangCat intercepts strings automatically via method swizzling.

**Over-The-Air Updates** - Fix typos and release new languages globally in milliseconds using LangCat's global edge network.

**Context-Aware AI** - Automatically drafts new translations utilizing your App Store description and developer comments.

**Xcode Plugin** - Automatically uploads `.xcstrings` diffs to the LangCat dashboard.

**Cross-Platform** - Complete iOS, macOS, tvOS, watchOS, and visionOS support.

**Safe Fallbacks** - Works perfectly offline. If a translation fails to fetch, it instantly falls back to the cache or your local `.xcstrings` catalog.

## Requirements

| Platform | Minimum Target |
|----------|----------------|
| iOS      | 15.0+          |
| macOS    | 12.0+          |
| tvOS     | 15.0+          |
| watchOS  | 8.0+           |

## Installation

LangCat is available through [Swift Package Manager](https://swift.org/package-manager/).

1. In Xcode, navigate to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/devsome-tech/lang-cat-ios.git`
3. Decide your dependency rule (Up to Next Minor Version is recommended) and Add Package.
4. Check the box for both `LangCat` and `LangCatSyncHelper` if you want automatic build phase syncing.

## Quickstart

### 1. Configure your API Key
Download your `LangCat-Info.plist` from your project dashboard at [LangCat](https://langcat.dev) and drag it into your Xcode project. Make sure it is checked in your **Copy Bundle Resources** build phase.

### 2. Initialize the SDK
Initialize LangCat as early as possible in your app's lifecycle to ensure translations are pulled before any views are rendered.

**Using SwiftUI (Async Initialization):**
The recommended approach for SwiftUI is to display a loading or splash screen while waiting for the newest strings to download.

```swift
import SwiftUI
import LangCat

@main
struct MyApp: App {
    @State private var isLangCatReady = false

    var body: some Scene {
        WindowGroup {
            if isLangCatReady {
                ContentView()
            } else {
                ProgressView("Checking for Translation Updates...")
                    .task {
                        // Blocks execution until latest dictionary is fetched OTA
                        try? await LangCat.initializeAsync()
                        isLangCatReady = true
                    }
            }
        }
    }
}
```

**Using SwiftUI (Sync Initialization):**
If you prefer not to block your UI with a loading screen, you can initialize LangCat synchronously in your App's `init`. 

> [!WARNING]
> Because synchronous initialization fetches updates in the background, your views will render using your local string catalog *first*. Once the network fetch completes, LangCat triggers a UI update, causing any modified strings to visibly "flicker" to their new values.

```swift
import SwiftUI
import LangCat

@main
struct MyApp: App {
    init() {
        // Fetches in the background. UI will render immediately with local cached text.
        LangCat.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```


**Using UIKit / AppDelegate (Sync Initialization):**
If you have an older app, you can initialize synchronously in `didFinishLaunchingWithOptions`.

```swift
import UIKit
import LangCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions... ) -> Bool {
        LangCat.initialize()
        return true
    }
}
```

### 3. Usage

**For SwiftUI Developers:**
SwiftUI evaluates `LocalizedStringKey` purely at compile-time, meaning it bypasses normal string loading. To use LangCat over-the-air strings in SwiftUI, you have two options:

#### Option A: Custom LC Components (Recommended)
Simply prefix your standard UI components with `LC`. They act as drop-in replacements, and because they use `@_disfavoredOverload`, your strings are still automatically extracted to your `Localizable.xcstrings` catalog by Xcode!

```swift
LCText("hello_world") // LangCat will instantly replace this with the OTA translation

LCLabel("settings_title", systemImage: "gear")

LCButton("submit_btn") {
    print("Tapped!")
}
```
*Available components: `LCText`, `LCLabel`, `LCButton`, `LCSecureField`, `LCTextField`, `LCDatePicker`, and `LCToggle`.*

#### Option B: Programmatic Evaluation
If you prefer not to use custom components, or you need to pass strings into standard native views that expect `String`, you can explicitly evaluate the text using `LangCat.localize()`:

```swift
Text(LangCat.localize("hello_world"))

// Works perfectly within other native modifiers or conditional views
NavigationLink(LangCat.localize("continue_btn"), destination: NextView())
```


**For UIKit & Programmatic Developers:**
LangCat automatically swizzles `Bundle.localizedString`, meaning your existing codebase requires zero changes.

```swift
// Automatically intercepted and translated over-the-air
let greeting = String(localized: "hello_world")
myLabel.text = NSLocalizedString("hello_world", comment: "")

// Or explicitly use the static method:
let explicit = LangCat.localize("hello_world")
```

## Syncing to the Dashboard

Whenever you make changes to your local strings or add new keys, you can manually trigger a synchronization directly from Xcode:

1. Right-click on your Xcode project folder in the Project Navigator.
2. Scroll down to **LangCatSyncCommand** in the context menu.
3. Click it and grant sandbox permissions if prompted. This will immediately push your local `.xcstrings` changes securely to LangCat.

## Dashboard

Log in to [langcat.dev](https://langcat.dev) to manage your projects, view AI-drafted strings, add team members, and hit **Publish** to send updates directly to your users' devices over the Edge.

## Contributing
Contributions are always welcome! Feel free to open issues or submit Pull Requests to help improve the SDK.

## License
LangCat is released under the MIT license. See [LICENSE](LICENSE) for details.
