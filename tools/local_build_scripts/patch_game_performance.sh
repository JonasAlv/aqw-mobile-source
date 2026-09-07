#!/bin/bash
set -e
echo "Extracting game.swf"
mkdir -p tmp_perf_patch
cp loader/gamefiles/game.swf tmp_perf_patch/game.swf
cd tmp_perf_patch
abcexport game.swf
rabcdasm game-0.abc

echo "Disabling Hit-Testing on Auras"
sed -i '/constructsuper      0/a \     getlocal0\n     pushfalse\n     initproperty        QName(PackageNamespace(""), "mouseEnabled")\n     getlocal0\n     pushfalse\n     initproperty        QName(PackageNamespace(""), "mouseChildren")' game-0/liteAssets/draw/playerAuras.class.asasm
sed -i '/constructsuper      0/a \     getlocal0\n     pushfalse\n     initproperty        QName(PackageNamespace(""), "mouseEnabled")\n     getlocal0\n     pushfalse\n     initproperty        QName(PackageNamespace(""), "mouseChildren")' game-0/liteAssets/draw/targetAuras.class.asasm

echo "Recompiling game.swf"
rabcasm game-0/game-0.main.asasm
abcreplace game.swf 0 game-0/game-0.main.abc
cp game.swf ../loader/gamefiles/game.swf
cd ..
rm -rf tmp_perf_patch

echo "Performance patches applied"
