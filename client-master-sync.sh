#!/bin/bash

DIRECTORY=$(dirname $0)
DIR=$1
LOG="$DIRECTORY/reports.log"
name=$(cat "$DIRECTORY/Conf/name")


cat $DIRECTORY/Conf/masters | while  read master ; do
 rsync -stats -cuarz  --delete-after $DIR -e ssh hermes@$master/Tmp/$name 2>> $LOG
done



