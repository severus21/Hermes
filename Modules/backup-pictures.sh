#!/bin/bash

if [ ! -e $1/Pictures ]
then
	mkdir $1/Pictures
fi


cp -rf /home/severus/Pictures/* $1/Pictures/
