# Installation & Autostart Guide

This guide explains how to build DockShelf as a standalone Mac application (`.app` bundle) and configure it to launch automatically when you log in.

## 1. Building the App

We have provided a script to build and package DockShelf as a proper `.app` bundle.

1.  Open **Terminal**.
2.  Navigate to the project directory:
    ```bash
    cd /path/to/DockShelf
    ```
3.  Run the packaging script:
    ```bash
    ./package_app.sh
    ```

    This will:
    - Build the executable in release mode (`swift build -c release`).
    - Create a `DockShelf.app` folder in the project directory.

## 2. Installation
1.  Move the generated `DockShelf.app` from the project folder to your **Applications** folder.
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

DockShelf will now launch automatically in the background every time you log in!
