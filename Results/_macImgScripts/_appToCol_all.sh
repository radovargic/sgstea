#!/bin/bash
#this script uses Imagemagic - corresponding executable on MacOS is "convert" comand
#Col append of all images in directory
here="`dirname \"$0\"`"
cd $here
inimg="`ls *.png`"
outimg="outcol.png"
echo COL APPENDING: $inimg TO: $outimg
convert -append $inimg  $outimg
read -n 1 -p "Press any key to continue"