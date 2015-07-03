#!/bin/bash

#Init
CURRENT_DIR=`dirname $0` #Dossier parent du script d'installation
DIRECTORY="/Backup/$(whoami)" #Dossier d'install
MODULES_DIRECTORY="Modules" #Emplacement des modules, relativement au dossier maitre
CONFIG_DIRECTORY="Conf" #Emplacement des modules, relativement au dossier maitre
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
MODULES_DIRECTORY=$DIRECTORY/$MODULES_DIRECTORY


##
#	Rsync install and conf
##
if [[ $rsync_flag -eq 1 ]]; then
	sudo apt-get install rsync cron
	
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

sudo mkdir -p $DIRECTORY
sudo chown -R $(whoami) $DIRECTORY
mkdir $CONFIG_DIRECTORY
mkdir $MODULES_DIRECTORY
mkdir $DIRECTORY/current
mkdir $DIRECTORY/last

	#Conf
	touch $CONFIG_DIRECTORY/masters
	echo $NAME > $CONFIG_DIRECTORY/name
	
	#Core
	touch $DIRECTORY/.c
	cp $CURRENT_DIR/client-handler.sh      $DIRECTORY/client-handler.sh
	cp $CURRENT_DIR/client-master-sync.sh  $DIRECTORY/client-master-sync.sh
	cp $CURRENT_DIR/Modules/*             $MODULES_DIRECTORY
	
#Droits
	chmod -R 711 $DIRECTORY
	chmod +x $DIRECTORY/client-handler.sh
	chmod +x $DIRECTORY/client-master-sync.sh

#Crontab
sudo gpasswd -a $(whoami) crontab
cat <(crontab -l) <(echo "1 * * * * $DIRECTORY/client-handler.sh") | crontab -


#On lance une premiere archive 
bash $DIRECTORY/client-handler.sh
