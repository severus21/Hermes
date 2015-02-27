#!/bin/bash
dir=$1/Divers
if [ ! -e  $dir ]
then
	mkdir $dir
fi

#Firefox
cp -ra /home/*/.mozilla $dir


#Liferea
#cp -rf /home/severus/.liferea* $dir
