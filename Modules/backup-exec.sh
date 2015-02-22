#!/bin/bash
newDir="$2"$(sed s/' '/'|-|'/g <<< ` dirname "$1"`)
newFile=$(sed s/' '/'|-|'/g <<< "$1")

if [[ -d $newDir ]]; then
	cp -ua "$1" "$newDir"	
	exit 0
fi

mkdir -p $newDir
cp -ua "$1" "$newDir"
