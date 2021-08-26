#!/bin/bash
#tento skript používa nástroj Imagemagic - spustitelný súbor na MacOS sa volá "convert"

here="`dirname \"$0\"`"
echo "PRACOVN|Y ADRESAR JE:  $here"
cd "$here" || exit 1

for filename in *.png; do
	echo trimming $filename
	convert "$filename" -trim "$filename"
done
read -n 1 -p "Stlac klavesu na skoncenie"