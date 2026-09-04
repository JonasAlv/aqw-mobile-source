#!/bin/bash
set -e

# ==========================================
# 1. Configuration
# ==========================================
DIR="upstream_check"
REPO="https://github.com/anthony-hyo/aqw-mobile.git"
API_URL="https://api.github.com/repos/anthony-hyo/aqw-mobile/releases/latest"
POCKET_PATCHES_DIR="pocket-patches"


# Ensure working directory is clean
if [[ -n $(git status -s) ]]; then
    echo "Error: You have uncommitted changes. Please commit or stash them before running this script."
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

echo "Switching to main branch to cleanly receive upstream updates..."
git checkout main

echo "Cleaning up old upstream check..."
rm -rf $DIR
mkdir -p $DIR/releases

# ==========================================
# 2. Sync Loader Source Code (Overlays/UI)
# ==========================================
echo "Cloning the latest upstream repository..."
git clone --depth 1 $REPO $DIR/source

echo "Syncing loader source code..."
# Copy Anthony's loader source into our repo
cp -r $DIR/source/loader/src/* loader/src/
cp -r $DIR/source/loader/worker-src/* loader/worker-src/ 2>/dev/null || true

# Re-apply Harman AIR SDK compatibility fixes for URLLoader
echo "Applying Harman AIR SDK compatibility fixes to loader source..."
sed -i 's/URLLoader(e.target).data/e.target.data/g' loader/src/util/HelperLoader.as 2>/dev/null || true
sed -i 's/URLLoader(event.target).data/event.target.data/g' loader/src/load/handlers/UpdateLoad.as 2>/dev/null || true
sed -i 's/URLLoader(event.target).data/event.target.data/g' loader/src/load/handlers/VersionLoad.as 2>/dev/null || true

# ==========================================
# 3. Sync ASASM Patches for game.swf
# ==========================================
echo "Fetching the latest release APK..."
ASSET_URL=$(curl -s $API_URL | grep "browser_download_url" | grep -i "armv8\.apk" | head -n 1 | cut -d '"' -f 4)
APK_NAME=$(basename "$ASSET_URL")

echo "Downloading $APK_NAME..."
curl -L -s -o "$DIR/releases/$APK_NAME" "$ASSET_URL"

echo "Extracting Anthony's game.swf from APK..."
unzip -p "$DIR/releases/$APK_NAME" assets/gamefiles/game.swf > "$DIR/anthony_game.swf"

echo "Downloading Vanilla game.swf from AE servers..."
# Get latest game version from AE API
VANILLA_FILE=$(curl -s https://game.aq.com/game/api/data/gameversion | grep -o '"sFile":"[^"]*"' | cut -d '"' -f 4)
curl -L -s -o "$DIR/vanilla_game.swf" "https://game.aq.com/game/gamefiles/$VANILLA_FILE"

echo "Decompiling SWFs to extract Anthony's patches..."
cd $DIR
abcexport vanilla_game.swf
abcexport anthony_game.swf
rabcdasm vanilla_game-0.abc
rabcdasm anthony_game-0.abc

echo "Identifying modified ASASM files..."
# Diff the two folders
diff -ur vanilla_game-0 anthony_game-0 | grep "^+++ anthony_game-0/" | awk '{print $2}' > modified_files.txt

echo "Updating local pocket-patches repository..."
POCKET_GAME_DIR="../$POCKET_PATCHES_DIR/pocket-patches/aqw/game"
# Clean out old game patches
rm -rf "$POCKET_GAME_DIR"/*
# Copy new patches and rename to .copy.asasm
while read filepath; do
    relpath="${filepath#anthony_game-0/}"
    dest="$POCKET_GAME_DIR/$relpath"
    dest_copy="${dest%.asasm}.copy.asasm"
    mkdir -p "$(dirname "$dest_copy")"
    cp "$filepath" "$dest_copy"
done < modified_files.txt

cd ..
# ==========================================
# 4. Clean Up & Manual Review
# ==========================================
echo "Cleaning up temporary files..."
rm -rf $DIR

echo "=================================================="
echo "Upstream Fetch Complete!"
echo "- The 'main' branch has been updated with the latest upstream code in your working directory."
echo "- You are currently on the 'main' branch with uncommitted changes."
echo ""
echo "Next steps:"
echo "1. Review the changes in loader/src/ and pocket-patches/"
echo "2. Run 'git commit' to save them to the 'main' branch."
echo "3. Switch back to your custom branch: git checkout $CURRENT_BRANCH"
echo "4. Merge the updates safely: git merge main"
echo "=================================================="
