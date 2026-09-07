# AQW Pocket Developer Workflow

This document explains how our repository works, what each branch is for, and how the various shell scripts tie everything together. 

---

## 1. Branch Strategy

We maintain two primary branches depending on what kind of modifications we are testing.

### `main`
- **Purpose:** The stable branch. This branch is strictly for **UI Overlays** (ActionScript 3 code in `loader/src/`).
- **How it works:** It grabs the *already-patched* `.swf` files from Anthony's upstream releases and compiles our custom UI (like the Auto-Combat menu and Smart rotation) on top of it.
- **Why we use it:** Fast builds. We don't have to re-decompile and modify the entire AQW game engine. 

### `custom-performance-tweaks`
- **Purpose:** The experimental branch. This branch is for **Deep Engine Modifications**.
- **How it works:** Instead of using Anthony's pre-built `.swf` files, it builds the entire game engine from the ground up using raw `ASASM` bytecode patches. 
- **Why we use it:** It allows us to inject heavy performance tweaks directly into the AQW engine (like disabling filters, optimizing rendering loops, fixing memory leaks). 

---

## 2. Build Scripts

Depending on which branch you are on, you will use different scripts to compile the APKs.

### `build.sh` (Used on `main`)
1. Downloads the latest pre-compiled `game.swf` from Anthony's upstream GitHub release.
2. Applies essential compatibility patches (like fixing sandbox errors and hardcoded servers).
3. Compiles our custom UI code (`loader/src/`) into `Mobile.swf`.
4. Packages everything into final APKs (`out/`).

### `build_performance.sh` (Used on `custom-performance-tweaks`)
Does everything `build.sh` does, but adds an extra step: **`patch_game_performance.sh`**. This script runs through the pristine `game.swf` and strips out laggy AQW engine code (like drop shadows, glow filters, heavy blending modes, and CPU-intensive mathematical loops) before packaging the APK.

### `build_from_source.sh` & `build_from_source_performance.sh`
Instead of downloading Anthony's pre-built `.swf` files, these scripts use a Python patcher (`patcher.py`) to build the SWFs directly from `ASASM` bytecode files. 
- Use these if you are actively editing `ASASM` engine files and want to test your changes locally.

---

## 3. How to Update with Upstream (Anthony's Repo)

When Anthony releases a new update to AQW Pocket, we need to sync our repository so we don't fall behind. You can automate this process using **`fetch_upstream.sh`**.

### `fetch_upstream.sh`
This is a powerful automation script that does the following:
1. **Syncs the UI:** Clones Anthony's latest source code and copies his `loader/src/` changes into ours.
2. **Fixes Compatibility:** Automatically runs `sed` commands to fix Harman AIR SDK compatibility bugs (so we can still compile locally).
3. **Extracts Engine Patches:** 
   - Downloads the Vanilla AQW `game.swf` from Artix Entertainment servers.
   - Downloads Anthony's newly released `game.swf`.
   - Decompiles *both* of them into raw `ASASM` bytecode.
   - Runs a `diff` comparison to perfectly extract *only* the code Anthony modified.
   - Saves these updated patches into our `pocket-patches` directory.

**How to use it:**
```bash
# 1. Run the sync script
./fetch_upstream.sh

# 2. Test to make sure the new update compiles
./build.sh

# 3. Commit the upstream changes
git add .
git commit -m "chore: sync with upstream"
git push origin main
```
