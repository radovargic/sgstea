#!/bin/bash
#this script uses Imagemagic - corresponding executable on MacOS is "convert" comand
#Row append of all images in directory
here="`dirname \"$0\"`"
cd $here
inimg="`ls *.png`"
outimg="outrow.png"
echo ROW APPENDING: $inimg TO: $outimg
convert +append $inimg  $outimg
read -n 1 -p "Press any key to continue"