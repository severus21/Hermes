#!/bin/bash
CURRENT_DIR=`dirname $0`
dir="$1/Codes"
if [ ! -e $dir ]
then
	mkdir $dir
fi


find /home \( -iname "*.ml" -o -iname "*.py" -o -iname "*.sh" -o -iname "*.cpp" -o -iname "*.h" -o -iname "*.php" -o -iname "*.js" -o -iname "*.css" -o -iname "*.html" \) -not \( -path "*cache*" -o -path "*/.*" \) -exec bash $CURRENT_DIR/backup-exec.sh {} $dir \;

