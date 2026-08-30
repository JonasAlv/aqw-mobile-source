# AQW Mobile Patches Documentation

This document explains the modifications made by the original author (Anthony) to the core AdventureQuest Worlds (`.swf`) files. These patches are required to make the web-based Flash game run properly as a native mobile application.

## 1. Asset Loading Interception (Caching & Overrides)
In the original web game, files are loaded dynamically from the Artix servers using `Loader.load(new URLRequest(url))`. 
Anthony replaced almost every instance of this across `Game.as`, `World.as`, and `Avatar.as` with a custom middleware: `rootClass.pocket.load()`.

**Why?** 
This delegates all file loading to the `Pocket` class (which lives in the `Mobile.swf` wrapper). This allows the mobile app to:
1. **Cache assets** locally on the phone so they don't have to be downloaded every time you enter a room.
2. **Override assets**, allowing the app to serve custom, mobile-optimized UI files directly from the APK instead of downloading the desktop UI from the server.

## 2. Hardcoded Mobile UIs
In several places, the game's logic was modified to strictly load the local mobile files. 
For example, in `Game.as` -> `onTravelMapComplete()`, the game normally parses the server's map data and downloads the map UI from `serverFilePath + sMap`. 

Anthony patched this to hardcode:
```as3
this.pocket.load(new Loader(), "app:/gamefiles/world-map.swf", ...);
```
This forces the game to load the custom, touch-friendly World Map that is bundled inside the mobile APK. Similar overrides were done for the Book of Lore and Character Select screens.

## 3. Exposing Private Combat & Movement State
To build the custom mobile UI (the on-screen Joystick and Skill buttons), the wrapper (`Mobile.swf`) needs to know what the player is doing. However, many variables in `Game.as` were strictly `private`.

Anthony added new `public` getters/setters to the root `Game` class:
* `justRan2` / `speed2`: Exposes movement and animation states for the joystick.
* `ActionResults` / `ActionResultsAura` / `ActionResultsMon`: Exposes the raw combat data arrays so the mobile UI knows when a skill is on cooldown, when an aura is applied, or when a monster is targeted.

## Conclusion
The `pocket-patches` (or ASASM modifications) essentially convert the original `game.swf` from a closed-box web player into an API-driven engine that the `Mobile.swf` wrapper can control, cache, and overlay touch controls onto.
