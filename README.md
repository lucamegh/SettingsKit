# SettingsKit 🛠

Clean settings management.

## Installation

SettingsKit is distributed using [Swift Package Manager](https://swift.org/package-manager). To install it into a project, simply add it as a dependency within your Package.swift manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/lucamegh/SettingsKit", from: "1.0.0")
    ],
    ...
)
```

## Usage

Let's start by declaring a type that contains all of your app's settings:

```swift
import SettingsKit

struct AppSettings: SettingsProtocol, Codable {

    var preferredTheme = Theme.system

    var isBackgroundRefreshEnabled = true
    
    ...
}
```

In order to manipulate this settings, you are going to need a `SettingsManager`. While you can create your own settings managers by providing a custom [`Storage`](https://github.com/lucamegh/Storage), SettingsKit provides two different built-in managers that will suite most use cases, `local` and `cloud`. Use `SettingsManager.local` to store your `Codable` settings in `UserDefaults.standard`; `SettingsManager.cloud` to store them in `NSUbiquitousKeyValueStore.default`. 

```swift
let settingsManager = SettingsManager<AppSettings>.local
settingsManager.preferredTheme = .dark // Thank you @dynamicMemberLookup!
```

Being an  `ObservableObject`, `SettingsManager` plays really well in SwiftUI environments:

```swift
struct SettingsView: View {
    
    @ObservedObject var settingsManager = SettingsManager<AppSettings>.local
    
    var body: some View {
        NavigationView {
            List {
                Toggle(
                    isOn: settingsManager.binding(for: \.isBackgroundRefreshEnabled)
                ) {
                    Text("Background Refresh")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}
```

And so it does in UIKit:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    settingsManager.publisher(for: \.isBackgroundRefreshEnabled)
        .assign(to: \.isOn, on: backgroundRefreshSwitch)
        .store(in: &cancellables)
}
```
