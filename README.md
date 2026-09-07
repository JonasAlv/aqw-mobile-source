# AQW-Pocket-Mod

This is a modified, feature-extended version of the community-built AQW Pocket client for AdventureQuest Worlds. 

This repository builds upon the original mobile client by adding performance improvements, quality of life features, and robust desktop support. 

> Disclaimer: This is an unofficial community project and is not affiliated with or endorsed by Artix Entertainment. Use at your own risk.

---

## Download

Grab the latest release from the [Releases](../../releases/latest) tab. Only download from this official repository.

- Android (Modern): `armv8.apk` (Recommended)
- Android (Older): `armv7.apk`
- Windows Desktop: `windows.zip` (Extract and run)

Note: If the standard Android app runs poorly on your device, try the `-direct` or `-gpu` APK alternatives included in the release.

## Extended Features

- Native Desktop Support: Fully working high-DPI scaling and custom UI layout editor for the Windows build.
- Automation Tools: Built-in AutoCombat (Smart and Custom modes) to simplify grinding.
- Performance Enhancements: Disabled heavy hit-testing on aura particles and implemented custom mobile performance patches for smoother framerates.
- Cross-Platform: Runs natively on Android and Windows via Adobe AIR with a fully adjustable on-screen joystick and skills bar.
- Discord RPC: Rich presence support on Desktop builds.

<img width="75%" alt="Mobile UI" src="https://github.com/user-attachments/assets/a2fca19f-5c63-4857-b3dc-b6b87a94c848" />

## Architecture and Development

This project uses an automated CI/CD pipeline via GitHub Actions. The repository strictly hosts the open-source ActionScript UI wrapper, while the proprietary game patches are injected during the cloud build process. 

For developers and technical details on how the patching system works, please refer to the documentation inside the `/docs` folder.

---
Notes:
- GrapheneOS users: Keep "Disable DCL via memory" off, as Adobe AIR's JIT compiler requires it to function.
