#!/bin/bash

# Dig.Tech Touchscreen Driver - macOS PKG Installer Builder
# This script creates a standard .pkg installer for non-technical users

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
PKG_BUILD_DIR="$BUILD_DIR/pkg_build"
PAYLOAD_DIR="$PKG_BUILD_DIR/payload"
SCRIPTS_DIR="$PKG_BUILD_DIR/scripts"

# Version and metadata
VERSION="1.0.0"
IDENTIFIER="com.digtech.touchscreendriver"
INSTALL_DIR="/usr/local/bin"
LAUNCH_AGENTS_DIR="/Library/LaunchAgents"
BINARY_NAME="DigTechTouchscreenDriver"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Dig.Tech Touchscreen Driver - macOS Installer Builder     ║"
echo "║  Version $VERSION                                                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Clean previous build
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$PAYLOAD_DIR"
mkdir -p "$SCRIPTS_DIR"

# Compile the driver in Release mode
echo "🔨 Compiling driver (Release mode)..."
cd "$PROJECT_DIR"
swiftc TouchscreenDriver.swift -o "$PROJECT_DIR/$BINARY_NAME" \
    -framework IOKit \
    -framework CoreFoundation \
    -framework CoreGraphics \
    -framework AppKit \
    -O -whole-module-optimization

echo "✅ Compilation successful"

# Create payload directory structure
echo "📦 Creating payload structure..."

# Binary goes to /usr/local/bin
mkdir -p "$PAYLOAD_DIR/usr/local/bin"
cp "$PROJECT_DIR/$BINARY_NAME" "$PAYLOAD_DIR/usr/local/bin/"
chmod 755 "$PAYLOAD_DIR/usr/local/bin/$BINARY_NAME"

# LaunchAgent goes to /Library/LaunchAgents (system-wide)
mkdir -p "$PAYLOAD_DIR/Library/LaunchAgents"
cp "$PROJECT_DIR/com.ymlaine.touchscreendriver.plist" "$PAYLOAD_DIR/Library/LaunchAgents/"
chmod 644 "$PAYLOAD_DIR/Library/LaunchAgents/com.ymlaine.touchscreendriver.plist"

# Documentation
mkdir -p "$PAYLOAD_DIR/usr/local/share/doc/digtech-touchscreen-driver"
cp "$PROJECT_DIR/README.md" "$PAYLOAD_DIR/usr/local/share/doc/digtech-touchscreen-driver/"
chmod 644 "$PAYLOAD_DIR/usr/local/share/doc/digtech-touchscreen-driver/README.md"

echo "✅ Payload created"

# Create pre-install script (runs before installation)
echo "📝 Creating pre-install script..."
cat > "$SCRIPTS_DIR/preinstall" << 'EOF'
#!/bin/bash
# Pre-installation tasks

# Stop any running instance
pkill -f "DigTechTouchscreenDriver" 2>/dev/null || true

# Unload LaunchAgent if present
launchctl unload /Library/LaunchAgents/com.ymlaine.touchscreendriver.plist 2>/dev/null || true

exit 0
EOF
chmod 755 "$SCRIPTS_DIR/preinstall"

# Create post-install script (runs after installation)
echo "📝 Creating post-install script..."
cat > "$SCRIPTS_DIR/postinstall" << 'EOF'
#!/bin/bash
# Post-installation tasks

INSTALL_DIR="/usr/local/bin"
BINARY_NAME="DigTechTouchscreenDriver"
LAUNCH_AGENT="/Library/LaunchAgents/com.ymlaine.touchscreendriver.plist"

# Make binary executable (should already be, but ensure it)
chmod 755 "$INSTALL_DIR/$BINARY_NAME"

# Load LaunchAgent to start at login
launchctl load "$LAUNCH_AGENT"

# Try to start immediately (may fail if permissions not granted yet - that's OK)
/usr/local/bin/DigTechTouchscreenDriver > /tmp/touchscreendriver.log 2>&1 &

exit 0
EOF
chmod 755 "$SCRIPTS_DIR/postinstall"

# Create Distribution XML (installer customization)
echo "📝 Creating distribution configuration..."
cat > "$PKG_BUILD_DIR/distribution.xml" << 'XMLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<installer-gui-script minSpecVersion="1">
    <title>Dig.Tech Touchscreen Driver</title>
    <organization identifier="com.digtech"/>
    <domains enable_localSystem="true"/>
    
    <pkg-ref id="com.digtech.touchscreendriver.pkg" onConclusion="none">DigTechTouchscreenDriver.pkg</pkg-ref>
    
    <options customize="never" require-scripts="false"/>
    <choices-outline>
        <line choice="default">
            <line choice="com.digtech.touchscreendriver.pkg"/>
        </line>
    </choices-outline>
    
    <choice id="default"/>
    <choice id="com.digtech.touchscreendriver.pkg" visible="false">
        <pkg-ref id="com.digtech.touchscreendriver.pkg"/>
    </choice>
    
</installer-gui-script>
XMLEOF

# Build the component package
echo "🔧 Building component package..."
pkgbuild \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --scripts "$SCRIPTS_DIR" \
    --root "$PAYLOAD_DIR" \
    --install-location "/" \
    "$PKG_BUILD_DIR/DigTechTouchscreenDriver.pkg"

echo "✅ Component package created"

# Create the final product archive (distribution package)
echo "📦 Creating distribution package..."
productbuild \
    --distribution "$PKG_BUILD_DIR/distribution.xml" \
    --package-path "$PKG_BUILD_DIR" \
    "$BUILD_DIR/DigTechTouchscreenDriver-$VERSION.pkg"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Package created successfully!"
echo ""
echo "📍 Location: $BUILD_DIR/DigTechTouchscreenDriver-$VERSION.pkg"
echo ""
echo "Installation instructions for users:"
echo "  1. Double-click the .pkg file"
echo "  2. Follow the installation wizard"
echo "  3. Enter your password when prompted"
echo "  4. Grant permissions in System Settings:"
echo "     → Privacy & Security → Accessibility"
echo "     → Privacy & Security → Input Monitoring"
echo "  5. Restart your Mac (or restart the driver)"
echo ""
echo "Commands for users:"
echo "  Status: pgrep -f DigTechTouchscreenDriver && echo 'Running' || echo 'Stopped'"
echo "  Logs:   tail -f /tmp/touchscreendriver.log"
echo "════════════════════════════════════════════════════════════"
