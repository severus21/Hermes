#!/bin/bash

if [ ! -e $1/Divers ]
then
	mkdir $1/Divers
fi

#Firefox
cp -rf /home/severus/.mozilla $1/Divers/

#Liferea
cp -rf /home/severus/.liferea* $1/Divers/
