# Auto Combat Implementation Documentation

This document outlines the technical implementation details for the custom Auto Combat features added to the AQW Mobile client, specifically focusing on Target Locking (MMID), the dedicated Menu UI, and the fix for the layout editor.

## 1. Target Locking (MMID)
**Goal:** Prevent the player from randomly wandering across the room to attack other monsters, keeping them locked to a specific monster spawn point.

**Implementation (`AutoCombat.as`):**
- When the player starts Auto Combat (either Smart or Custom), the script checks if they currently have a target selected (`avatar.target`).
- If a target exists, it extracts the unique **Monster Map ID (MMID)** from either `target.dataLeaf.MonMapID` or `target.objData.MonMapID` and stores it in the `_lockedMMID` variable.
- During the `onTick` loop, if the player loses their target (e.g., the monster dies), the script searches for a new target using `world.getMonstersByCell()`. 
- As it iterates through available monsters, it compares each monster's MMID against the saved `_lockedMMID`. It will only call `world.setTarget(m)` if the MMID matches, ensuring the player stays exactly at their chosen farm spot.

## 2. Dedicated Auto Combat Menu
**Goal:** Provide a clean, organized UI for toggling Auto Combat modes rather than cluttering the "Controls" tab.

**Implementation (`Overlay.as`):**
- A new dedicated tab was created in the settings UI using `new Menu("Auto Combat")`.
- We added specific toggle buttons to this menu:
  - **Smart Auto Combat:** Calls `AutoCombat.toggleSmart(_pocket)`
  - **Custom Auto Combat:** Calls `AutoCombat.toggleCustom(_pocket)`
- The configuration button that opens the prompt to set the custom rotation (e.g., `5432`) is also housed natively in this new menu tab.

## 3. Fixing the Edit Layout Mode Crash
**Goal:** Fix a bug where entering "Edit Layout" mode failed to render the directional movement arrows (handles) on custom UI buttons, breaking the customization feature.

**Implementation (`LayoutController.as`):**
- **The Issue:** The game registers UI elements (like skill bar icons) for the layout editor. However, when changing maps or reloading UI, some elements are destroyed and lose their `parent` container, but remain in the layout tracking array. When the layout loop iterated over these orphaned objects and attempted to attach a handle (`parent.addChild(handle)`), it threw a null reference exception, crashing the loop before it could finish adding handles to the rest of the UI.
- **The Fix:** We injected simple `null` checks (`if (parent == null) { return; }`) into the `showHandles` and `onMouseMove` functions. This safely skips orphaned elements, allowing the loop to successfully attach handles to all valid UI buttons.


## 4. Auto Quest Turn-in System
**Goal:** Create a lightweight, safe mechanism to repeatedly turn in completed quests to automate farming tasks alongside Auto Combat.

**Implementation (`AutoQuest.as`):**
- **Safe Native Function:** We hook directly into the client's native `world.tryQuestComplete()` function. By checking if a quest's status is officially flagged as `"c"` (complete) by the client, we ensure we only attempt turn-ins when requirements are legitimately met, preventing server bans.
- **Multiple IDs & Choice Rewards:** The user can input a comma-separated list of Quest IDs. If a quest requires a specific item choice as a reward, the user can append it using a colon (e.g., `1234:5678`), allowing the system to pass the selected Item ID to the server.
- **Anti-Spam Defenses:** When multiple quests complete simultaneously, the system staggers their turn-ins by `break`ing the loop after one successful request. Additionally, a strict 6-second cooldown map (`_lastTurnIns`) per quest ID prevents duplicate network packets from firing during server lag, fully eliminating the "Slow down" red message warnings.
