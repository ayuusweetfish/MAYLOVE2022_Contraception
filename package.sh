#!/bin/sh

# LOVE_WIN=~/Downloads/love-11.4-win32

# Package .love
rm -rf build
mkdir -p build/game
cp -r *.lua res build/game
rm build/game/res/1574853606.ttf
cd build

for f in `find . -name "*.lua"`; do
  luamin -f $f > tmp
  mv tmp $f
done

(cd game && zip -r Contraception.zip *)
mv game/Contraception.zip Contraception.love

# Web
love.js --compatibility --title "Contraception" Contraception.love Contraception-web
cp ../index.html Contraception-web/index.html
rm -rf Contraception-web/theme

cd ..
