# AQW Mobile: Architecture & Workflow Guide

This document explains the branching strategy and build scripts used in this repository. If the original maintainers disappear, this guide will help you understand how to build, maintain, and optimize the game.

## Branching Strategy

We use a strict two-branch system to separate stable game code from aggressive performance hacks:

* **`main`**: The pure, stable branch. This branch is meant to track Anthony's hand-merged APKs and contains NO experimental bytecode hacks. It is your safe haven.
* **`custom-performance-tweaks`**: The experimental branch. This is where heavy ASASM bytecode manipulation lives (e.g., stripping vector filters, disabling hit-testing, native GPU scaling). It is built for maximum FPS on low-end devices.

## The Upstream Sync Script

### `fetch_upstream.sh`
* **What it does:** Automatically syncs our local repository with Anthony's upstream changes. It pulls his latest open-source loader UI, re-applies our Harman AIR SDK fixes, downloads his latest pre-built APK, decompiles it alongside a vanilla AE server SWF, isolates all of his ASASM changes, and updates our `pocket-patches` folder so we can build from source.
* **When to use it:** When Anthony releases a new APK update on GitHub. Run this on your `main` branch to update your repository, commit the changes, and then merge `main` into `custom-performance-tweaks` so your performance branch gets the new content.

## The Build Scripts

There are 4 distinct scripts in the root directory. You will use a different script depending on what you are trying to accomplish.

### 1. `build.sh` (The Standard Daily Driver)
* **What it does:** Extracts the pre-compiled `app-release.apk` (Anthony's stable build), applies mandatory crash fixes, and repacks it.
* **When to use it:** 90% of the time on the `main` branch when you just want a stable, vanilla game.
* **Speed:** Extremely fast.

### 2. `build_performance.sh` (The Max FPS Daily Driver)
* **What it does:** Extracts Anthony's stable APK, but applies `patch_game_performance.sh` to inject aggressive ASASM optimizations before repacking.
* **When to use it:** When you are on the `custom-performance-tweaks` branch and want maximum FPS.
* **Speed:** Fast.

### 3. `build_from_source.sh` (The Emergency Backup)
* **What it does:** Ignores the cached APK. Instead, it downloads the **live `game.swf`** directly from Artix Entertainment's servers, decompiles it using `rabcdasm`, injects our `pocket-patches` via Python, and recompiles it.
* **When to use it:** When the game has a major update, the mobile app stops working, and Anthony hasn't uploaded a new base APK in months. 
* **Warning:** Because the Python script overwrites entire `.asasm` files, it might accidentally overwrite recent bug fixes made by Artix. It may also introduce minor decompilation bugs. Use only in emergencies.
* **Speed:** Slow (requires Python decompilation).

### 4. `build_from_source_performance.sh` (The Emergency Backup + Max FPS)
* **What it does:** Downloads the live game from Artix servers, applies the Python patches, AND applies the aggressive performance optimizations.
* **When to use it:** When you are relying on the emergency backup but still want the FPS hacks.

## The Patching Scripts

These scripts are automatically triggered by the build scripts above. You rarely need to run them manually, but here is what they do:

* **`patch_game.sh`**: Injects essential crash-prevention code. Specifically, it hides generic ActionScript errors that would normally cause the Harman AIR engine to instantly crash the mobile app.
* **`patch_game_performance.sh`**: (Only exists on the custom branch). Injects extreme optimizations:
  1. Wipes all `GlowFilter` and `DropShadowFilter` properties globally.
  2. Disables `mouseEnabled` and `mouseChildren` on heavy particle Auras.
  3. Relies on `loader/Mobile-app.xml` being set to `<requestedDisplayResolution>standard</requestedDisplayResolution>` for GPU upscaling.
