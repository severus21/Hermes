#!/bin/bash

#Init
DIRECTORY=$(dirname $0)
STORAGE_DIRECTORY="Data"
TMP_DIRECTORY="Tmp"
CONFIG_DIRECTORY="Conf"
LOG="h.log"

if [[ "$DIRECTORY" != "." ]]; then
	STORAGE_DIRECTORY=$DIRECTORY/$STORAGE_DIRECTORY
	TMP_DIRECTORY=$DIRECTORY/$TMP_DIRECTORY
	CONFIG_DIRECTORY=$DIRECTORY/"Conf"
	LOG=$DIRECTORY/"h.log"
fi

day=$(date +%d);
lastDay=""
month=$(date +%m);
lastMonth=""
year=$(date +%Y);
lastYear=""

valid=1




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
		if [[ ! -e $CONFIG_DIRECTORY/name && "$(cat $CONFIG_DIRECTORY/name)" != "" && "$(cat $CONFIG_DIRECTORY/name)" != "default" ]]; then
			valid=0;
			echo "error : [Conf/name] invalid" >> $LOG
		fi 
		
		if [[ ! -e $CONFIG_DIRECTORY/slaves ]]; then
			valid=0;
			echo "error : [Conf/slaves] invalid" >> $LOG
		fi
	}

	check_build(){
		check_conf
		
		if [[ ! -d $STORAGE_DIRECTORY ]]; then 
			valid=0;
			echo "error : [Data/] invalid" >> $LOG
		fi
		
		if [[ ! -d $TMP_DIRECTORY ]]; then 
			valid=0;
			echo "error : [Tmp/] invalid" >> $LOG
		fi
		
		if [[ ! -e $DIRECTORY/.day ]]; then 
			valid=0;
			echo "error : [.day] invalid" >> $LOG
		fi
		
		if [[ ! -e $DIRECTORY/.month ]]; then 
			valid=0;
			echo "error : [.month] invalid" >> $LOG
		fi
		
		if [[ ! -e $DIRECTORY/.year ]]; then 
			valid=0;
			echo "error : [.year] invalid" >> $LOG
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


	#On défini l'état
	lastDay=$(cat $DIRECTORY/.day) 
	lastMonth=$(cat $DIRECTORY/.month) 
	lastYear=$(cat $DIRECTORY/.year) 
	
	if [[ "$lastDay" = "" ]]; then 
		lastDay=$day 
	fi
	
	if [[ "$lastMonth" = "" ]]; then 
		lastMonth=$month 
	fi
	
	if [[ "$lastYear" = "" ]]; then 
		lastYear=$year 
	fi

	#On met à jour les fichiers
	echo $day > $DIRECTORY/.day
	echo $month > $DIRECTORY/.month
	echo $year > $DIRECTORY/.year
	
DAILY_PATH=$STORAGE_DIRECTORY/$year/$month/$day
if [ ! -d $DAILY_PATH ]
then
	mkdir -p $DAILY_PATH
fi

#$dir à le nom du client
for dir in $(ls $TMP_DIRECTORY)
do
	mkdir -p $DAILY_PATH/$dir
	rsync -cuar $TMP_DIRECTORY/$dir $DAILY_PATH/
	tar -cvf "$DAILY_PATH/$dir.tar" $DAILY_PATH/$dir && xz -z -6e "$DAILY_PATH/$dir.tar"
	rm "$DAILY_PATH/$dir.tar"
	rm -r $DAILY_PATH/$dir
done

##
#	Update storage node
##

	#  
	#  name: prune_month
	#  @param $1 -> year, $2 -> month
	#  
	prune_month(){	
			if [[ "$1"!="$lastYear" && "$2" != "$lastMonth" ]]; #On élague, une seule sauvegarde par mois
			then  
				rm -rf $STORAGE_DIRECTORY/$1/$2/{02,03,04,05,06,07,08,09,{10..31}}
			fi 
	}
		
	for year in $(ls $STORAGE_DIRECTORY)
	do
		echo "year= $year"
		for month in $(ls $STORAGE_DIRECTORY/$year)
		do
			echo "month= $month"
			prune_month $year $month
		done
	done

##
#	Update storage node end
##

#Synchronise with slaves
bash master-slave-sync.sh $STORAGE_DIRECTORY
