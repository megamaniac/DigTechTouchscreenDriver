# Dig.Tech Touchscreen Driver - Packaging Guide

This directory contains scripts and resources for packaging the Dig.Tech Touchscreen Driver as a user-friendly macOS installer.

## Building the Installer Package

### Quick Start

```bash
cd packaging
./build_pkg.sh
```

This creates a professional `.pkg` installer at `build/DigTechTouchscreenDriver-1.0.0.pkg`

### What It Does

The build script:
1. ✅ Compiles the Swift driver in Release mode with full optimizations
2. ✅ Creates a proper payload directory structure
3. ✅ Includes pre/post-install hooks for smooth setup
4. ✅ Generates a distribution package with system requirements checking
5. ✅ Creates a standard macOS installer UI

### System Requirements Check

The installer automatically verifies:
- **macOS 10.15 (Catalina) or later** — driver requires modern frameworks
- **Sufficient disk space** — typically <50MB

### Installation Flow

When users double-click the `.pkg`:

1. **Pre-install**: Stops any running driver instance
2. **Install**: 
   - Copies binary to `/usr/local/bin/DigTechTouchscreenDriver`
   - Installs LaunchAgent to `/Library/LaunchAgents/`
   - Copies documentation to `/usr/local/share/doc/`
3. **Post-install**: 
   - Enables automatic launch at login
   - Starts the driver immediately (may fail if permissions not granted - that's OK)

### File Locations

After installation, users will find:

```
/usr/local/bin/DigTechTouchscreenDriver          (executable binary)
/Library/LaunchAgents/
  └─ com.ymlaine.touchscreendriver.plist         (auto-start configuration)
/usr/local/share/doc/digtech-touchscreen-driver/
  └─ README.md                                    (documentation)
/tmp/touchscreendriver.log                        (runtime logs)
```

## Next Steps: Code Signing & Notarization

**⚠️ Important for distribution outside your organization:**

For users on macOS 10.15+, Apple requires notarization. Without it, Gatekeeper blocks installation.

### 1. Code Sign the Binary

```bash
# Using your Apple Developer certificate
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  build/pkg_build/payload/usr/local/bin/DigTechTouchscreenDriver
```

### 2. Sign the Package

```bash
productbuild \
  --sign "Developer ID Installer: Your Name" \
  --distribution distribution.xml \
  --package-path build/pkg_build \
  DigTechTouchscreenDriver-signed.pkg
```

### 3. Notarize with Apple

```bash
xcrun notarytool submit DigTechTouchscreenDriver-signed.pkg \
  --apple-id your-apple-id@example.com \
  --team-id YOUR_TEAM_ID \
  --password your-app-specific-password
```

For complete notarization details, see [Apple's Code Signing Guide](https://developer.apple.com/help/xcode/notarizing-macos-software-before-distribution).

## Distribution Options

### Option A: GitHub Releases (Easiest)
1. Build the package: `./build_pkg.sh`
2. Upload `build/DigTechTouchscreenDriver-1.0.0.pkg` to a GitHub Release
3. Users download and double-click to install

### Option B: Homebrew Cask
1. Fork/create a Homebrew tap repository
2. Create a formula pointing to your GitHub release
3. Users install with: `brew install your-tap/DigTechTouchscreenDriver`

### Option C: Your Website
1. Host the `.pkg` on your website
2. Users download and install directly

## Customization

Edit `build_pkg.sh` to customize:

```bash
VERSION="1.0.0"                    # Package version
IDENTIFIER="com.digtech..."        # Bundle identifier (for macOS uniqueness)
INSTALL_DIR="/usr/local/bin"       # Where binary goes
BINARY_NAME="DigTechTouchscreenDriver"  # Executable name
```

## Troubleshooting Build Issues

**Error: "pkgbuild not found"**
- Install Xcode Command Line Tools: `xcode-select --install`

**Error: "Permission denied" on install**
- Run with `sudo` if installing to system locations (already handled in script)

**Compiled binary is too large**
- Add `-Osize` flag to `swiftc` for smaller binary (slightly slower)

**Post-install script not running**
- Ensure script has executable permissions (script already sets this)
- Check `/var/log/install.log` for installer errors

## Testing Before Release

```bash
# Install locally to test
sudo installer -pkg build/DigTechTouchscreenDriver-1.0.0.pkg -target /

# Verify installation
ls -la /usr/local/bin/DigTechTouchscreenDriver
launchctl list | grep digtech

# Test driver
pgrep -f DigTechTouchscreenDriver && echo "Running" || echo "Stopped"
tail -f /tmp/touchscreendriver.log
```

## Uninstalling for Users

```bash
# Stop the driver
launchctl unload /Library/LaunchAgents/com.ymlaine.touchscreendriver.plist

# Remove files
rm /usr/local/bin/DigTechTouchscreenDriver
rm /Library/LaunchAgents/com.ymlaine.touchscreendriver.plist
rm -rf /usr/local/share/doc/digtech-touchscreen-driver/
```

## Files in This Directory

| File | Purpose |
|------|---------|
| `build_pkg.sh` | Main script to build the `.pkg` installer |
| `README.md` | This file |

## Version History

- **1.0.0** - Initial release
