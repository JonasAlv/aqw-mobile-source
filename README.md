# AQW Pocket

**AQW Pocket** is a free, community-built mobile and desktop client for AdventureQuest Worlds.

> **Disclaimer:** This is an unofficial community project, not affiliated with or endorsed by Artix Entertainment. Use at your own risk.

---

## Download

Grab the latest release from the [Releases](../../releases/latest) tab! **Only download from this official repository.**

- **Android (Modern):** `armv8.apk` (Recommended)
- **Android (Older):** `armv7.apk`
- **Windows Desktop:** `windows.zip` (Just extract and run!)

*Note: If the standard Android app runs poorly on your device, try the `-direct` or `-gpu` APK alternatives.*

## Features

- **Native App:** Runs natively on Android and Windows via Adobe AIR.
- **Mobile Controls:** On-screen joystick, skills bar, and fully adjustable UI.
- **Auto-Updates:** In-game notifications when a new GitHub release is available.
- **Discord RPC:** Rich presence support on Desktop builds.

<img width="75%" alt="Mobile UI" src="https://github.com/user-attachments/assets/a2fca19f-5c63-4857-b3dc-b6b87a94c848" />

## Security & Architecture

- **100% Open Source:** The app is compiled completely automatically on GitHub Actions using the latest vanilla game files. What you see in the code is exactly what gets built.
- **Secure Login:** Logins occur directly with Artix Entertainment servers. Your passwords are never stored.
- **Fair Play:** This client does not include cheats, botting tools, or automation.

*(For developers and technical details on how the Python patching system works, see [README_ARCHITECTURE.md](README_ARCHITECTURE.md).)*

---
**Notes:** 
- **GrapheneOS:** Keep "Disable DCL via memory" off; Adobe AIR's JIT requires it.
