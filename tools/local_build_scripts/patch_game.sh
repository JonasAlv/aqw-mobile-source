#!/bin/bash
set -e
echo "Extracting game.swf"
mkdir -p tmp_patch
cp loader/gamefiles/game.swf tmp_patch/game.swf
cd tmp_patch
abcexport game.swf
rabcdasm game-0.abc

echo "Patching Game.class.asasm"
sed -i 's/callpropvoid.*"allowDomain".*/pop\n      pop/g' game-0/Game.class.asasm
sed -i 's/callpropvoid.*"allowDomain".*/pop\n      pop/g' game-0/FBListener.class.asasm
sed -i 's/flag SEALED//g' game-0/Game.class.asasm

echo "Patching LoaderContext"
sed -i '/constructprop       Multiname("LoaderContext",.*), 2/a \
      dup\
      pushtrue\
      setproperty         Multiname("allowCodeImport", [PackageNamespace("")])' game-0/Game.class.asasm

echo "Patching Game.class.asasm (server paths)"
python3 -c '
import sys

with open("game-0/Game.class.asasm", "r") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "QName(PackageNamespace(\"\"), \"serverGamePath\")" in line or "QName(PackageNamespace(\"\"), \"serverFilePath\")" in line or "QName(PackageNamespace(\"\"), \"serverURL\")" in line:
        if "findproperty" in line:
            if "pushstring" in lines[i+1] and "\"\"" in lines[i+1]:
                lines[i+1] = "    pushstring          \"https://game.aq.com/game/\"\n"
        elif "trait slot" in line and "Utf8(\"\")" in line:
            lines[i] = line.replace("Utf8(\"\")", "Utf8(\"https://game.aq.com/game/\")")

with open("game-0/Game.class.asasm", "w") as f:
    f.writelines(lines)
'

echo "Recompiling game.swf"
rabcasm game-0/game-0.main.asasm
abcreplace game.swf 0 game-0/game-0.main.abc
cp game.swf ../loader/gamefiles/game.swf
cd ..
rm -rf tmp_patch

echo "Patches applied"
