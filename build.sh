#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Downloading pre-compiled game files..."
mkdir -p loader/gamefiles

if [ ! -f "loader/gamefiles/game.swf" ]; then
  echo "No local patched SWFs found. Downloading vanilla game files as a fallback..."
  # Fetching the main game swf version to construct the URL
  GAME_VERSION_JSON=$(wget -qO- https://game.aq.com/game/api/data/gameversion)
  GAME_SFILE=$(echo $GAME_VERSION_JSON | grep -o '"sFile":"[^"]*"' | cut -d'"' -f4)

  wget -q "https://game.aq.com/game/gamefiles/$GAME_SFILE" -O loader/gamefiles/game.swf
  wget -q "https://game.aq.com/game/gamefiles/news/Map-UI_r38.swf" -O loader/gamefiles/world-map.swf
  wget -q "https://game.aq.com/game/gamefiles/news/spiderbook3.swf" -O loader/gamefiles/book-of-lore.swf
  wget -q "https://game.aq.com/game/gamefiles/interface/CharSelect/charselect.swf" -O loader/gamefiles/character-select.swf
else
  echo "Found local patched gamefiles. Skipping vanilla download."
fi

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
  -output /tmp/Mobile_code.swf \
  loader/src/Pocket.as

echo "Injecting updated code into Mobile.swf..."
cp loader/Mobile_base.swf loader/Mobile.swf
abcexport /tmp/Mobile_code.swf
abcreplace loader/Mobile.swf 0 /tmp/Mobile_code-0.abc


if [ ! -d "android_sdk" ]; then
    echo "Downloading Android SDK..."
    mkdir -p android_sdk/cmdline-tools
    cd android_sdk/cmdline-tools
    
    # Download Android command line tools
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    rm cmdline-tools.zip
    
    # Extract puts it in a folder named "cmdline-tools", rename to "latest" to respect standard structure
    mv cmdline-tools latest
    cd ../..
    
    echo "Accepting licenses and installing build tools..."
    # The new SDK manager requires a newer Java version (Java 17+). We'll use java-26 here.
    export JAVA_HOME=/usr/lib/jvm/java-26-openjdk
    export PATH=$JAVA_HOME/bin:$PATH
    
    yes | ./android_sdk/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1
    ./android_sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-33" "build-tools;33.0.2" "platform-tools" > /dev/null
    echo "Android SDK installed successfully!"
fi

echo "Copying SWF files to loader..."
mkdir -p loader/gamefiles

echo "Building local APK..."
# ADT (Adobe AIR) requires Java 11, so we switch back
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$JAVA_HOME/bin:$PATH

./AIRSDK_Linux/bin/adt -package \
  -target apk-captive-runtime \
  -arch armv8 \
  -storetype JKS \
  -keystore aqwpocket_keystore.jks \
  -storepass aqwpocket \
  -keypass aqwpocket \
  AQWPocket-armv8.apk \
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

echo "Done! Generated AQWPocket-armv8.apk"
