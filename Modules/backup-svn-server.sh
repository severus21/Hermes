#!/bin/bash

if [ ! -e $1/Svn ]
then
	mkdir $1/Svn
fi

#On copie les depots
cp -rf /var/svn/* $1/Svn
 
