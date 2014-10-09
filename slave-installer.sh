#!/bin/bash

#Init
CURRENT_DIR=`dirname $0` 			#Dossier parent du script d'installation
DIRECTORY="/home/hermes"  			#Dossier d'install

rsync_flag=0;# 0 -> rien , 1 -> install et configuration de rsync
#On traite les options 
while getopts d: name   ## les options acceptant un paramètres sont suivies de ":"
  do
    case $name in
        d)
            DIRECTORY="$OPTARG"
            ;;
        ?)
			printf "Usage: %s: [-d directory] args\n" $1
            exit 2
            ;;
    esac
done


##
#	Rsync install and conf
##
if [[ $rsync_flag -eq 1 ]]; then
	sudo apt-get install rsync
	sudo cp $CURRENT_DIR/Conf/rsync  /etc/default/rsync
	sudo cp Config/rsyncd.conf /etc/rsyncd.conf 
	
	sudo echo "[hermes_rsync]" >> /etc/rsyncd.conf
	sudo echo "path = $TMP_DIRECTORY" >> /etc/rsyncd.conf
	sudo echo "port = 873" >> /etc/rsyncd.conf
    sudo echo "read only = false" >> /etc/rsyncd.conf
	
	
	sudo groupadd rsync
	sudo useradd hermes
	sudo passwd hermes
	sudo gpasswd -a rsync hermes
	
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
	chmod -R 711 $DIRECTORY
	chown -R hermes:rsync $DIRECTORY
