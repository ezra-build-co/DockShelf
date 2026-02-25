# DockShelf Prototype

This is a prototype macOS utility app that acts as a temporary file shelf next to the Dock.

## Features
- **Placement**: Automatically positions itself next to the Dock (Bottom-Right, Bottom-Left, etc.).
- **Persistence**: Stores file references across app launches.
- **Drag & Drop**: Drag files in to store, drag out to use.
- **UI**: SwiftUI with frosted glass effect and grid layout.

## Setup Instructions

1.  **Open in Xcode**:
    - Double-click the `Package.swift` file (or the folder containing it).
    - Xcode will open the project.
    - Select the `DockShelf` scheme.
    - Choose "My Mac" as the destination.

2.  **Build & Run**:
    - Press `Cmd + R` to build and run.
    - The app will launch. It may not appear in the Dock (it runs as an accessory app), but look for a transparent panel near your Dock.
    - **Note**: Since this is a prototype running from Xcode, you might need to grant it accessibility permissions if prompted (though it shouldn't need them for basic window positioning).
    - **Note**: If the app doesn't appear, check the console output in Xcode. It might be hidden if the Dock is hidden.

3.  **Using the App**:
    - Drag a file from Finder onto the panel to add it.
    - Click and drag an item from the panel to move it out.
    - Click "Clear" to remove all items.

## Implementation Details

- **`ShelfModel.swift`**: Manages the list of files and persistence.
- **`ShelfView.swift`**: SwiftUI interface.
- **`ShelfWindow.swift`**: Custom `NSPanel` configuration.
- **`DockPositionManager.swift`**: Handles Dock detection logic.
- **`AppDelegate.swift`**: App lifecycle management.

## Notes
- Thumbnails are generated using `QLThumbnailGenerator`.
- The window is configured to be non-activating (`.nonactivatingPanel`) to avoid stealing focus.
- Requires macOS 12.0 or later.
# DockShelf
