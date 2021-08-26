#!/bin/bash
#tento skript používa nástroj Imagemagic - spustitelný súbor na MacOS sa volá "convert"

here="`dirname \"$0\"`"
echo "PRACOVN|Y ADRESAR JE:  $here"
cd "$here" || exit 1

for filename in *.png; do
	echo Bordering $filename ...
	convert "$filename" -bordercolor black -border 4 "$filename"
done
read -n 1 -p "Stlac klavesu na skoncenie"