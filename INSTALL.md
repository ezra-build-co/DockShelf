# Installation & Autostart Guide

This guide explains how to install DockShelf as a standalone application and configure it to launch automatically when you log in.

## 1. Building the App

### Option A: Using Xcode (Recommended)
1.  Open the project in Xcode (double-click `Package.swift`).
2.  Select the **DockShelf** scheme in the top toolbar (ensure target is "My Mac").
3.  Go to **Product > Archive**.
4.  Once the archive is built, the Organizer window will open.
5.  Click **Distribute App**.
6.  Select **Copy App** (or "Development" if "Copy App" isn't available for unsigned code).
7.  Export the app to a folder (e.g., your Desktop).
8.  You will find `DockShelf.app` inside the exported folder.

### Option B: Using Terminal
If you prefer command line tools:

```bash
# Navigate to the project directory
cd /path/to/DockShelf

# Build for release
swift build -c release

# The executable will be in the build directory, typically:
# .build/release/DockShelf
# Note: This produces a raw binary, not a full .app bundle.
# For a proper macOS app experience, Option A is preferred.
```

## 2. Installation
1.  Move the `DockShelf.app` file to your **Applications** folder.
2.  Double-click it to run.
3.  **Note**: Since this app is not signed by an Apple Developer ID, you might see a security warning. To open it:
    - Right-click (Control-click) on `DockShelf.app`.
    - Select **Open**.
    - Click **Open** in the dialog box.

## 3. Enable Autostart (Launch on Login)
To have DockShelf start automatically when you restart your Mac:

1.  Open **System Settings**.
2.  Go to **General > Login Items** (on macOS Ventura/Sonoma) or **Users & Groups > Login Items** (on older macOS).
3.  Click the **+** button under "Open at Login".
4.  Navigate to your **Applications** folder and select `DockShelf.app`.
5.  Click **Open**.

DockShelf will now launch automatically every time you log in!
