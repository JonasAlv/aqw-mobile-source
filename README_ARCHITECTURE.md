# AQW Mobile Architecture

This document outlines the modern architecture of the AQW Mobile port and the transition from the legacy structure.

## Overview
The goal of this project is to maintain a mobile wrapper for AdventureQuest Worlds (AQW). The wrapper (`Mobile.swf`) intercepts the game's loading sequence, injects joystick controls, exposes private game state, and handles mobile-specific events.

## Legacy Architecture vs. Modern Architecture

### The Old Way (Legacy)
Previously, the repository relied on a complex multi-repository structure:
- A main repository containing the Android wrapper source.
- A secondary `patches` submodule containing **pre-compiled binary `.swf` files**.
- Developers had to manually extract, decompile, patch, and recompile the `.swf` files on their local machine, then push those binaries to the `patches` repo.
- The GitHub Action blindly downloaded these pre-compiled binaries and packaged them.
- This was extremely error-prone, caused merge conflicts with binary files, and made tracking actual code changes impossible.

### The New Way (Standalone)
We have modernized the project into a single, standalone repository:
- **No more pre-compiled SWFs in source control!** Only raw `.asasm` source code changes are tracked.
- **`pocket-patches/`**: This directory now contains only the raw, human-readable `.asasm` files representing the exact modifications we make to the game.
- **Automated Python Patcher**: A custom `python3 patcher.py` script downloads the *latest* vanilla game files directly from Artix Entertainment's servers, decompiles them on the fly, applies our modifications, and recompiles the game.
- **Automated CI/CD**: The GitHub Action now builds everything dynamically. When you trigger a release, the GitHub Action automatically downloads the `D` compiler, builds `RABCDAsm` from source, runs the Python patcher, and generates the final APKs (Android) and ZIP bundles (Windows Desktop) using Adobe AIR.

## Update System
1. **GitHub Releases**: When the GitHub Action finishes, it uploads the APKs and Windows ZIPs to a new GitHub Release on `JonasAlv/aqw-mobile`.
2. **In-Game Checker**: The mobile wrapper (`Mobile.swf`) queries the GitHub API (`/releases/latest`) on startup.
3. **Prompt**: If the latest release tag (e.g., `v3.1.2`) is newer than the `versionNumber` in `Mobile-app.xml`, the game displays an update prompt allowing players to directly download the new APK.

## Making Changes
To edit the game logic (e.g., joystick or UI), you can provide patches in `pocket-patches/`:

1. **Full File Replacement**: Name your file ending in `.copy.asasm` (e.g., `Game.class.copy.asasm`). The Python script will completely overwrite the vanilla file with yours.
2. **Method Insertion**: Name your file ending in `.method.asasm` (e.g., `onEnterFrame.method.asasm`). The Python script will dynamically inject the body of your text file directly into the matching trait method of the vanilla `.class.asasm` file, avoiding the need to track entire files for small logic changes.
