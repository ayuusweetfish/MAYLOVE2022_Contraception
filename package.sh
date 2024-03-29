#!/bin/sh

# LOVE_WIN=~/Downloads/love-11.4-win32

# Package .love
rm -rf build
mkdir -p build/game
cp -r *.lua res build/game
rm build/game/res/ZCOOL_Kuaile.ttf
cd build

for f in `find . -name "*.lua"`; do
  luamin -f $f > tmp
  mv tmp $f
done

(cd game && zip -r Contraception.zip *)
mv game/Contraception.zip Contraception.love

# Windows
cp -r ${LOVE_WIN} Contraception-windows
cat Contraception-windows/love.exe Contraception.love > Contraception-windows/MAYLOVE2022_Contraception.exe
rm Contraception-windows/{love.exe,OpenAL32.dll,changes.txt,game.ico,license.txt,love.ico,lovec.exe,readme.txt}

zip Contraception-windows -r Contraception-windows

# Web
love.js --compatibility --title "Contraception" Contraception.love Contraception-web
cp ../index.html Contraception-web/index.html
rm -rf Contraception-web/theme

zip Contraception-web -r Contraception-web

cd ..
