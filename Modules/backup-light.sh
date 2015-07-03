#!/bin/bash
CURRENT_DIR=`dirname $0`
dir="$1/Light"
if [ ! -e $dir ]
then
	mkdir $dir
fi

cp -ra "/home/$(whoami)/Github" $dir
cp -ra "/home/$(whoami)/Documents" $dir
cp -ra "/home/$(whoami)/Projets" $dir
