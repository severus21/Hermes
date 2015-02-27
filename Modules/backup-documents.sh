#!/bin/bash
CURRENT_DIR=`dirname $0`
dir="$1/Documents"
if [ ! -e $dir ]
then
	mkdir $dir
fi


find /home \( -iname "*.pdf" -o -iname "*.tex" -o -iname "*.ods" -o -iname "*.odt" -o -iname "*.odp" -o -iname "*.odg" \) -not \( -path "*cache*" -o -path "*/.*" \) -exec bash $CURRENT_DIR/backup-exec.sh {} $dir \;

