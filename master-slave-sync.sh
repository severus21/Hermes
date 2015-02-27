#!/bin/bash

DIR=$1
DIRECTORY=$(dirname $0)
name=$(cat "$DIRECTORY/Conf/name")

cat $DIRECTORY/Conf/slaves | while  read slave ; do
	rsync -stats -cuarz $DIR -e ssh hermes@$slave/$name
done



