# AQW Mobile Architecture

This document outlines the modern architecture of the AQW Mobile port and the transition from the legacy structure.

## Overview
The goal of this project is to maintain a mobile wrapper for AdventureQuest Worlds (AQW). The wrapper (`Mobile.swf`) intercepts the game's loading sequence, injects joystick controls, exposes private game state, and handles mobile-specific events.

## Legacy Architecture vs. Modern Architecture

### The Old Way (Legacy)
Previously, the repository relied on a complex multi-repository structure containing pre-compiled binary `.swf` files. Then, it transitioned to hosting decompiled Artix Entertainment ActionScript (`.asasm`) files directly in the public repository, applying them dynamically with a Python script. Both approaches posed major DMCA and copyright risks.

### The New Way (Two-Repo DMCA-Safe Architecture)
We have modernized the project into a completely clean, two-repository split system:

#### 1. The Public Wrapper Repository (`aqw-mobile-source`)
This repository. It is 100% open source and contains **zero** proprietary AE code. 
- It contains the ActionScript UI logic (the joystick, menus, config).
- It contains the build scripts (`build.sh` and GitHub Actions).
- When triggered, it securely connects to the Private Repository via a `PATCH_TOKEN`, downloads the pre-patched game files, compiles the UI, and bundles the final APK.
- If you run the build script locally without patched files, it safely falls back to downloading vanilla game files so the build won't fail.

#### 2. The Private Patch Repository (`pocket-patches`)
A hidden, secure repository that contains the decompiled Artix Entertainment `.asasm` files and the Python patching engine (`patcher.py`).
- Because it is private, it is completely hidden from DMCA bots and copyright scanners.
- It contains its own GitHub Action. When patches are updated, it downloads the vanilla game from AE, applies the patches via `RABCDAsm`, compiles the modified `.swf` files, and saves them as a hidden workflow artifact (`patched-gamefiles`).

## Update System
1. **GitHub Releases**: When the public GitHub Action finishes compiling the APKs and Windows ZIPs, it uploads them to a new GitHub Release.
2. **In-Game Checker**: The mobile wrapper (`Mobile.swf`) queries the GitHub API (`/releases/latest`) on startup.
3. **Prompt**: If the latest release tag (e.g., `v3.1.2`) is newer than the `versionNumber` in `Mobile-app.xml`, the game displays an update prompt allowing players to directly download the new APK.

## Making Changes
* **To change the Mobile UI or Wrapper logic**: Commit your ActionScript changes directly to this public repository.
* **To change game patches or fix core `.swf` logic**: Commit your `.asasm` files to the private `pocket-patches` repository. Wait for the private action to finish building, then trigger a new release in the public repository.
