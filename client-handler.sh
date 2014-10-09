#!/bin/bash

#Init
DIRECTORY=$(dirname $0)
MODULES_DIRECTORY="Modules"
CONFIG_DIRECTORY="Conf"
LOG="h.log"

if [[ "$DIRECTORY" != "." ]]; then
	MODULES_DIRECTORY=$DIRECTORY/"Modules"
	CONFIG_DIRECTORY=$DIRECTORY/"Conf"
	LOG=$DIRECTORY/"h.log"
fi

valid=1
lastDay="-1"
hour=$(date +%H);
day=$(date +%d);


##
#	Check zone
##

	#  
	#  name: unknown
	#  @param  $1 error code, $2 description
	#  @return
	#  
	error(){
		echo "Error $1  :  $2"
		exit 2
	}

	check_conf(){
		#Verif du name
		if [[ ! -e "$CONFIG_DIRECTORY/name" && "$(cat $CONFIG_DIRECTORY/name)" != "" && "$(cat $CONFIG_DIRECTORY/name)" != "default" ]]; then
			valid=0;
			echo "error : [Conf/name] invalid" >> $LOG
		fi 
		
		if [[ ! -e "$CONFIG_DIRECTORY/masters" ]]; then
			valid=0;
			echo "error : [Conf/masters] invalid" >> $LOG
		fi
	}

	check_build(){
		check_conf
		
		if [[ ! -d "$DIRECTORY/current" ]]; then 
			valid=0;
			echo "error : [current/] invalid" >> $LOG
		fi
		
		if [[ ! -d "$DIRECTORY/last" ]]; then 
			valid=0;
			echo "error : [last/] invalid" >> $LOG
		fi
		
		if [[ ! -e "$DIRECTORY/.c" ]]; then 
			valid=0;
			echo "error : [.c] invalid" >> $LOG
		fi
		
		if [ $valid -eq 0 ]
		then
			error 1 "Invalid build, see log for more details"
		fi
	}

	check_build
##
#	Chek zone end
##


	#On recupère le n° du dernier jour et on en profite pr faire une maj
	lastDay=$(cat $DIRECTORY/.c)
	echo $day > $DIRECTORY/.c

if [ "$day" != "$lastDay" ]
then
	#On déplace les données vers last
	rm -r $DIRECTORY/last/*
	i=0
	for file in $(ls $DIRECTORY/current/) 
	do
		if [ $i -eq 0 ]
		then
			rsync -cuar  $DIRECTORY/current/$file $DIRECTORY/last
		fi
		i=$i+1
	done
	rm -r $DIRECTORY/current/*
fi

hourDirectory="$DIRECTORY/current/$hour"
if [ ! -e $hourDirectory ]
then
	mkdir $hourDirectory
fi



#On rempli le dossier de sauvegarde
files=`ls $MODULES_DIRECTORY | grep "backup-" `	
for fichier in $files
do
	sh $MODULES_DIRECTORY/$fichier $hourDirectory
done


#End
sh $DIRECTORY/client-master-sync.sh "$hourDirectory/"

#On rebuild le dossier de sauvegarde, on supprime les fichiers temporairess
files=`ls $MODULES_DIRECTORY | grep "prune-" `	
for fichier in $files
do
	sh $MODULES_DIRECTORY/$fichier $hourDirectory
done
