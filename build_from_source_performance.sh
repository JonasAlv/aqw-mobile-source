#!/bin/bash
set -e

cd "$(dirname "$0")"

mkdir -p out_source_performance
mkdir -p loader/gamefiles

echo "=================================================="
echo "BUILDING SWFS FROM SOURCE VIA PYTHON PATCHER"
echo "=================================================="
# Run the Python patcher to build game.swf, world-map.swf, etc. from vanilla + pocket-patches ASASM
python3 tools/legacy_python_scripts/patcher.py

echo "Applying essential compatibility patches to built game.swf..."
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
  -output build_cache/Mobile_code_source.swf \
  loader/src/Pocket.as

echo "Injecting updated code into Mobile.swf..."
cp loader/Mobile_base.swf loader/Mobile.swf
abcexport build_cache/Mobile_code_source.swf
abcreplace loader/Mobile.swf 0 build_cache/Mobile_code_source-0.abc

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

echo "Building local APK from source..."
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$JAVA_HOME/bin:$PATH

for render in auto gpu direct; do
  sed -i "s|<renderMode>.*</renderMode>|<renderMode>$render</renderMode>|" loader/Mobile-app.xml
  
  if [ "$render" = "auto" ]; then
      suffix=""
  else
      suffix="-$render"
  fi
  
  APK_NAME="out_source_performance/AQWPocket-Source-Performance-armv8$suffix.apk"
  echo "Building $APK_NAME ($render mode)..."
  ./AIRSDK_Linux/bin/adt -package \
    -target apk-captive-runtime \
    -arch armv8 \
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
