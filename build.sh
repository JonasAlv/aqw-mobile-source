#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Running Python Patcher..."
python3 patcher.py

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
    ./android_sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-33" "build-tools;33.0.2" > /dev/null
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
