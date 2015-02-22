#!/bin/bash
CURRENT_DIR=`dirname $0`
dir="$1/Pictures"
if [ ! -e $dir ]
then
	mkdir $dir
fi


find /home \( \( -iname "*.jpeg" -o -iname "*.jpg"  -o -iname "*.png" \) -not \( -path "*cache*" -o -path "*/.*" -o -path "*$1*" \) \)  -exec bash $CURRENT_DIR/backup-exec.sh {} $dir \;

#/media ??

