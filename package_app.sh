#!/bin/bash

# Configuration
APP_NAME="DockShelf"
BUNDLE_ID="com.dockshelf.app"
EXECUTABLE_NAME="DockShelf"

echo "📦 Building $APP_NAME for release..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "📂 Creating .app bundle..."
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Clean up previous build
rm -rf "$APP_BUNDLE"

# Create directories
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp ".build/release/${EXECUTABLE_NAME}" "$MACOS_DIR/"

# Create Info.plist
cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/> <!-- Use false if you want a Dock icon, true for accessory app -->
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Make executable
chmod +x "${MACOS_DIR}/${EXECUTABLE_NAME}"

echo "✅ Created ${APP_BUNDLE} successfully!"
echo "👉 You can now move '${APP_BUNDLE}' to your /Applications folder."
