#!/bin/bash

DIRECTORY=$(dirname $0)
DIR=$1
name=$(cat "$DIRECTORY/Conf/name")

cat $DIRECTORY/Conf/masters | while  read master ; do
 rsync -stats -cuarz  --delete-after $DIR -e ssh hermes@$master/Tmp/$name
done



