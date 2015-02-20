#!/bin/bash

#Init
CURRENT_DIR=`dirname $0` 			#Dossier parent du script d'installation
DIRECTORY="/home/hermes"  			#Dossier d'install
DATA_DIRECTORY="Data" 				#Emplacement des modules, relativement au dossier maitre
TMP_DIRECTORY="Tmp" 				#Emplacement des modules, relativement au dossier maitre
CONFIG_DIRECTORY="Conf" 			#Emplacement des modules, relativement au dossier maitre
NAME="default"

rsync_flag=0; # 0 -> rien , 1 -> install et configuration de rsync
#On traite les options 
while getopts d:n:i name   ## les options acceptant un paramètres sont suivies de ":"
  do
    case $name in
        d) #Tmp
            DIRECTORY="$OPTARG"
            ;;
        n) #Scripts 
            NAME="$OPTARG"
            ;;
        i)
			rsync_flag=1;
			;;
        ?)
			printf "Usage: %s: [-d directory] [-n name] args\n" $1
            exit 2
            ;;
    esac
done


CONFIG_DIRECTORY=$DIRECTORY/$CONFIG_DIRECTORY
DATA_DIRECTORY=$DIRECTORY/$DATA_DIRECTORY
TMP_DIRECTORY=$DIRECTORY/$TMP_DIRECTORY


##
#	Rsync install and conf
##
if [[ $rsync_flag -eq 1 ]]; then
	sudo apt-get install rsync
	sudo cp $CURRENT_DIR/Conf/rsync  /etc/default/rsync
	sudo cp Conf/rsyncd.conf /etc/rsyncd.conf 
	
	sudo echo "[hermes_rsync]" >> /etc/rsyncd.conf
	sudo echo "path = $TMP_DIRECTORY" >> /etc/rsyncd.conf
	sudo echo "port = 873" >> /etc/rsyncd.conf
    sudo echo "read only = false" >> /etc/rsyncd.conf
	
	
	sudo groupadd hermes
	sudo useradd hermes
	sudo passwd hermes
	sudo gpasswd -a hermes hermes
	
	if [ -e /etc/init.d/firewall.sh ]
	then
		sudo echo "" >> /etc/init.d/firewall.sh
		sudo echo "#Rsync" >> /etc/init.d/firewall.sh
		sudo echo "iptables -t filter -A OUTPUT -p tcp --dport 873 -j ACCEPT" >> /etc/init.d/firewall.sh
		sudo echo "iptables -t filter -A INPUT -p tcp --dport 873 -j ACCEPT" >> /etc/init.d/firewall.sh
	else
		echo""
		printf "Warming : firewall unconfigure for rsync"
		echo"" 
	fi
fi
	
#Construction de l'architecture
if [[ -d $DIRECTORY ]]; then
	echo""
	printf "Error : location of the main directory is already used"
	echo""
	exit 2
fi

mkdir -p $DIRECTORY
mkdir $CONFIG_DIRECTORY
mkdir $DATA_DIRECTORY
mkdir $TMP_DIRECTORY

	#Conf
	touch $CONFIG_DIRECTORY/slaves
	echo $NAME > $CONFIG_DIRECTORY/name
	
	#Core
	touch $DIRECTORY/.day
	touch $DIRECTORY/.month
	touch $DIRECTORY/.year
	cp $CURRENT_DIR/master-handler.sh      $DIRECTORY/master-handler.sh
	cp $CURRENT_DIR/master-slave-sync.sh  $DIRECTORY/master-slave-sync.sh
	
#Droits
	chmod -R 711 $DIRECTORY
	chmod +x $DIRECTORY/master-handler.sh
	chmod +x $DIRECTORY/master-slave-sync.sh
	chown -R hermes:rsync $DIRECTORY
