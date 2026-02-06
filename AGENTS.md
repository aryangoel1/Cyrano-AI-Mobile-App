# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

iOS mobile app built with SwiftUI and Swift 5. Targets iPhone and iPad.

- **Bundle ID:** `Cyrano-AI.Cyrano-AI-Mobile-App`
- **Minimum iOS:** 26.2
- **Entry point:** `Cyrano_AI_Mobile_AppApp.swift` → `ContentView.swift`

## Build Commands

Build for simulator:
```bash
xcodebuild -project "Cyrano AI Mobile App.xcodeproj" -scheme "Cyrano AI Mobile App" -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Build for device (requires signing):
```bash
xcodebuild -project "Cyrano AI Mobile App.xcodeproj" -scheme "Cyrano AI Mobile App" -destination 'generic/platform=iOS' build
```

Clean build:
```bash
xcodebuild -project "Cyrano AI Mobile App.xcodeproj" -scheme "Cyrano AI Mobile App" clean
```

## Running Tests

No test target exists yet. To add tests, create a test target in Xcode and run:
```bash
xcodebuild -project "Cyrano AI Mobile App.xcodeproj" -scheme "Cyrano AI Mobile App" -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Code Style

- Uses Swift's strict concurrency model with `@MainActor` as default isolation
- SwiftUI declarative views with `#Preview` macros for live previews
- Auto-generated Info.plist (no manual plist file)

## Project Structure

```
Cyrano AI Mobile App/
├── Cyrano_AI_Mobile_AppApp.swift   # App entry point (@main)
├── ContentView.swift               # Root view
└── Assets.xcassets/                # App icons, colors, images
```
