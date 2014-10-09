#!/bin/bash

if [ ! -e $1/Documents ]
then
	mkdir $1/Documents
fi

cp -rf /home/severus/Documents/* $1/Documents/
