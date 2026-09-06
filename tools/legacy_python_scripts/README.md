# Legacy Python Patcher Scripts

This folder contains the old Python-based toolchain that was originally used to parse, decompress, and patch ActionScript (`.asasm`) bytecode manually into vanilla `game.swf` files before recompiling them with `rabcasm`.

These scripts are kept here for historical reference and backup purposes in case you ever want to manually build Anthony's `game.swf` from scratch (using his `.copy.asasm` files).

## Why are they no longer used?
Our modern build pipeline (`build-app.yml` and `build.sh`) has completely deprecated this Python toolchain by:
1. Instantly downloading the pre-patched `game.swf` directly from Anthony's compiled release APKs.
2. Using blazing fast `sed` bash scripts (`patch_game.sh` and `patch_game_performance.sh`) to apply our custom Harman SDK and performance tweaks on the fly.
