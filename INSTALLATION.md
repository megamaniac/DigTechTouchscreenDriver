# Dig.Tech Touchscreen Driver - Installation Guide

## 🚀 For End Users

### System Requirements

- **macOS 10.15 (Catalina)** or later
- **Dig.Tech CineEdge Display** (or compatible Corsair Xeneon Edge touchscreen)
- Connected via USB-C

### Installation Steps

#### 1. Download the Installer
- Go to the [Releases page](https://github.com/megamaniac/DigTechTouchscreenDriver/releases)
- Download the latest `DigTechTouchscreenDriver-X.X.X.pkg` file
- Save it to your Downloads folder

#### 2. Run the Installer
1. Open **Finder** and navigate to **Downloads**
2. Double-click `DigTechTouchscreenDriver-X.X.X.pkg`
3. The installer window opens
4. Click **Continue** to proceed
5. Review the license (if shown)
6. Select installation location (default is **Macintosh HD**)
7. Click **Install**
8. Enter your **Administrator password** when prompted
9. Click **Install Software** to confirm

#### 3. Grant Required Permissions
The driver needs two permissions to work:

**Step A: Accessibility Permission**
1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Privacy & Security** → **Accessibility**
3. Click the **lock icon** 🔒 to make changes (enter password if prompted)
4. Click the **+** button
5. Navigate to **Applications** → **Utilities** → **Terminal.app**
6. Select it and click **Open**
7. The Terminal should now be listed in Accessibility

**Step B: Input Monitoring Permission**
1. In **System Settings**, go to **Privacy & Security** → **Input Monitoring**
2. Click the **lock icon** 🔒 to make changes
3. Click the **+** button
4. Navigate to **Applications** → **Utilities** → **Terminal.app**
5. Select it and click **Open**
6. The Terminal should now be listed in Input Monitoring

⚠️ **Note**: If you don't see these permission pages, run the driver once first and macOS will prompt you.

#### 4. Start Using Your Touchscreen
- **If you just installed**: Restart your Mac, or manually start the driver
- **The driver will now run automatically** at login
- Your touchscreen should work immediately!

### Verify Installation

Open Terminal and run:

```bash
pgrep -f DigTechTouchscreenDriver && echo "✅ Driver is running" || echo "❌ Driver is not running"
```

### View Logs

If something isn't working, check the driver logs:

```bash
tail -f /tmp/touchscreendriver.log
```

Press **Ctrl+C** to exit log view.

---

## 🛠️ For Advanced Users / Developers

### Manual Installation from Source

If you prefer to build from source:

```bash
git clone https://github.com/megamaniac/DigTechTouchscreenDriver.git
cd DigTechTouchscreenDriver
./install.sh
```

### Building the PKG Package

If you want to create your own installer:

```bash
cd packaging
./build_pkg.sh
```

This creates: `packaging/build/DigTechTouchscreenDriver-1.0.0.pkg`

### Code Signing and Notarization

For distribution outside your organization, you must sign and notarize the package:

1. **Sign the binary**:
   ```bash
   codesign --deep --force --verify --verbose \
     --sign "Developer ID Application: Your Name" \
     /usr/local/bin/DigTechTouchscreenDriver
   ```

2. **Sign the package**:
   ```bash
   productbuild --sign "Developer ID Installer: Your Name" \
     DigTechTouchscreenDriver-signed.pkg
   ```

3. **Notarize with Apple**:
   ```bash
   xcrun notarytool submit DigTechTouchscreenDriver-signed.pkg \
     --apple-id your-apple-id@example.com \
     --team-id YOUR_TEAM_ID \
     --password your-app-specific-password
   ```

See [Apple's Developer Documentation](https://developer.apple.com/help/xcode/notarizing-macos-software-before-distribution) for details.

---

## 🔧 Managing the Driver

### Start/Stop the Driver

**Check if running**:
```bash
pgrep -f DigTechTouchscreenDriver && echo "Running" || echo "Stopped"
```

**Stop the driver**:
```bash
launchctl unload ~/Library/LaunchAgents/com.ymlaine.touchscreendriver.plist
```

**Start the driver**:
```bash
launchctl load ~/Library/LaunchAgents/com.ymlaine.touchscreendriver.plist
```

### View Driver Logs

```bash
tail -f /tmp/touchscreendriver.log
```

---

## 🗑️ Uninstallation

To remove the driver completely:

```bash
# Stop the driver
launchctl unload /Library/LaunchAgents/com.ymlaine.touchscreendriver.plist

# Remove driver files
sudo rm /usr/local/bin/DigTechTouchscreenDriver
sudo rm /Library/LaunchAgents/com.ymlaine.touchscreendriver.plist
sudo rm -rf /usr/local/share/doc/digtech-touchscreen-driver/

# (Optional) Remove permissions from System Settings as described above
```

---

## ❓ Troubleshooting

### "Installation failed with error code X"

**Common causes**:
- Insufficient disk space (need ~100MB)
- Permissions issues (try restarting your Mac)
- Conflicting software (close other apps and try again)

### Touchscreen is not working after installation

1. **Check if driver is running**:
   ```bash
   pgrep -f DigTechTouchscreenDriver
   ```
   If no output → driver isn't running

2. **Grant permissions** (see "Grant Required Permissions" above)

3. **Check the logs**:
   ```bash
   tail -20 /tmp/touchscreendriver.log
   ```

4. **Ensure touchscreen is connected**:
   - Check USB-C connection
   - Look in **System Information** → **USB** for "Dig.Tech" or "Corsair"

5. **Restart the driver**:
   ```bash
   pkill -f DigTechTouchscreenDriver
   sleep 2
   launchctl load ~/Library/LaunchAgents/com.ymlaine.touchscreendriver.plist
   ```

### Touchscreen clicks at wrong position

1. Run the HID analyzer to recalibrate:
   ```bash
   cd /path/to/DigTechTouchscreenDriver
   ./run_analyzer.sh
   ```

2. Touch the screen corners and note the X/Y values

3. Update calibration values in `TouchscreenDriver.swift`:
   ```swift
   var touchscreenMaxX: CGFloat = 16383  // Your X max
   var touchscreenMaxY: CGFloat = 9599   // Your Y max
   ```

4. Rebuild and reinstall

### macOS says the package is damaged

**This usually means**:
- The package wasn't downloaded completely (re-download)
- Your Mac's security settings are blocking it

**To fix**:
1. Delete the `.pkg` file
2. [Clear downloads](https://support.apple.com/en-us/HT201949)
3. Re-download from [Releases](https://github.com/megamaniac/DigTechTouchscreenDriver/releases)
4. Verify the file size matches (should be listed in release notes)

---

## 📞 Getting Help

- **Check logs first**: `tail -f /tmp/touchscreendriver.log`
- **Review the main [README.md](README.md)**
- **Open an Issue**: [GitHub Issues](https://github.com/megamaniac/DigTechTouchscreenDriver/issues)
- **Check Troubleshooting above**

---

## ✅ Success!

Once the driver is working:
- ✅ Touchscreen clicks work in all applications
- ✅ Driver starts automatically at login
- ✅ Logs are available in `/tmp/touchscreendriver.log`
- ✅ You can manage it with `launchctl` commands

Enjoy your touchscreen! 🎉
