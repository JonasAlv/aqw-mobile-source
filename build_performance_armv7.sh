#!/bin/bash
set -e

cd "$(dirname "$0")"

CACHE_DIR="build_cache"
API_URL="https://api.github.com/repos/anthony-hyo/aqw-mobile/releases/latest"

mkdir -p loader/gamefiles
mkdir -p out_performance
mkdir -p "$CACHE_DIR"

if [ -f "$CACHE_DIR/current_version.txt" ]; then
    CACHED_VERSION=$(cat "$CACHE_DIR/current_version.txt")
else
    CACHED_VERSION=""
fi

echo "Checking GitHub for the latest upstream release..."
LATEST_ASSET_URL=$(curl -s $API_URL | grep "browser_download_url" | grep -i "armv7\.apk" | head -n 1 | cut -d '"' -f 4)

if [ -z "$LATEST_ASSET_URL" ]; then
    echo "Failed to fetch from GitHub API (rate limit or empty). Using cached version."
    LATEST_VERSION=$CACHED_VERSION
else
    LATEST_VERSION=$(basename "$LATEST_ASSET_URL")
fi

if [ "$LATEST_VERSION" != "$CACHED_VERSION" ] || [ ! -f "$CACHE_DIR/pristine_swfs/game.swf" ]; then
    echo "New version detected ($LATEST_VERSION) or cache is missing! Downloading..."
    rm -rf "$CACHE_DIR/pristine_swfs"
    mkdir -p "$CACHE_DIR/pristine_swfs"
    
    UPSTREAM_APK="$CACHE_DIR/upstream.apk"
    wget -q "$LATEST_ASSET_URL" -O "$UPSTREAM_APK"
    
    echo "Extracting game files..."
    unzip -o -q "$UPSTREAM_APK" assets/gamefiles/game.swf -d "$CACHE_DIR/"
    unzip -o -q "$UPSTREAM_APK" assets/gamefiles/world-map.swf -d "$CACHE_DIR/"
    unzip -o -q "$UPSTREAM_APK" assets/gamefiles/book-of-lore.swf -d "$CACHE_DIR/"
    unzip -o -q "$UPSTREAM_APK" assets/gamefiles/character-select.swf -d "$CACHE_DIR/"
    
    mv "$CACHE_DIR/assets/gamefiles/"*.swf "$CACHE_DIR/pristine_swfs/"
    rm -rf "$CACHE_DIR/assets"
    
    echo "$LATEST_VERSION" > "$CACHE_DIR/current_version.txt"
else
    echo "Already up-to-date with latest upstream version ($CACHED_VERSION). Using pristine cache."
fi

echo "Copying pristine SWFs to loader directory..."
cp "$CACHE_DIR/pristine_swfs/"*.swf loader/gamefiles/

echo "Applying essential compatibility patches to game.swf..."
./patch_game.sh

echo "Applying mobile performance patches to game.swf..."
./patch_game_performance.sh

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$JAVA_HOME/bin:$PATH
export AIR_HOME=/home/me/aqw-mobile-source/AIRSDK_Linux
export PATH=$AIR_HOME/bin:$PATH

echo "Compiling WorkerMain.swf..."
mkdir -p loader/gamefiles/embed
$AIR_HOME/bin/amxmlc loader/worker-src/WorkerMain.as -source-path+=loader/src -source-path+=loader/worker-src -output loader/gamefiles/embed/WorkerMain.swf -swf-version=18

echo "Compiling Mobile.swf from source..."
./AIRSDK_Linux/bin/amxmlc \
  +configname=airmobile \
  -define+=POCKET::IS_DESKTOP,false \
  -define+=POCKET::IS_MOBILE,true \
  -source-path+=loader/src \
  -source-path+=loader/worker-src \
  -output "$CACHE_DIR/Mobile_code.swf" \
  loader/src/Pocket.as

echo "Injecting updated code into Mobile.swf..."
cp loader/Mobile_base.swf loader/Mobile.swf
abcexport "$CACHE_DIR/Mobile_code.swf"
abcreplace loader/Mobile.swf 0 "$CACHE_DIR/Mobile_code-0.abc"

if [ "$1" == "--test" ]; then
  echo "Launching instant AIR Debug Launcher (ADL)..."
  ./AIRSDK_Linux/bin/adl -profile mobileDevice loader/Mobile-app.xml -extdir loader/libs/
  exit 0
fi

if [ ! -d "android_sdk" ]; then
    echo "Downloading Android SDK..."
    mkdir -p android_sdk/cmdline-tools
    cd android_sdk/cmdline-tools
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    rm cmdline-tools.zip
    mv cmdline-tools latest
    cd ../..
    export JAVA_HOME=/usr/lib/jvm/java-26-openjdk
    export PATH=$JAVA_HOME/bin:$PATH
    yes | ./android_sdk/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1
    ./android_sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-33" "build-tools;33.0.2" "platform-tools" > /dev/null
    echo "Android SDK installed successfully!"
fi

echo "Building local APK..."
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$JAVA_HOME/bin:$PATH

for render in auto gpu direct; do
  sed -i "s|<renderMode>.*</renderMode>|<renderMode>$render</renderMode>|" loader/Mobile-app.xml
  
  if [ "$render" = "auto" ]; then
      suffix=""
  else
      suffix="-$render"
  fi
  
  APK_NAME="out_performance/AQWPocket-Performance-armv7$suffix.apk"
  echo "Building $APK_NAME ($render mode)..."
  ./AIRSDK_Linux/bin/adt -package \
    -target apk-captive-runtime \
    -arch armv7 \
    -storetype JKS \
    -keystore aqwpocket_keystore.jks \
    -storepass aqwpocket \
    -keypass aqwpocket \
    $APK_NAME \
    loader/Mobile-app.xml \
    -platformsdk android_sdk \
    -C loader \
      Mobile.swf \
      icons/icon-36x36.png \
      icons/icon-48x48.png \
      icons/icon-72x72.png \
      icons/icon-96x96.png \
      icons/icon-144x144.png \
      icons/icon-192x192.png \
      gamefiles/game.swf \
      gamefiles/world-map.swf \
      gamefiles/book-of-lore.swf \
      gamefiles/character-select.swf

  echo "Done! Generated $APK_NAME"
done
