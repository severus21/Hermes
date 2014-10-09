#!/bin/bash

if [ ! -e $1/Mysql ]
then
	mkdir $1/Mysql
fi

	
#Auth
login="root"
pwd="rj7@kAv;8d7_e(E6:m4-w&"

# -d : on ne sauve que la structure
#Base à sauvegarder
#mysqldump -u $login -p $pwd "base">$1/"Mysql"/"base.sql"
mysqldump -u $login -p$pwd "scientiavulgaria">$1/"Mysql"/"scientiavulgaria.sql"
mysqldump -u $login -p$pwd "forum">$1/"Mysql"/"forum.sql"

#Table à sauvegarder
#mysqldump -u $login -p $pwd "base.table">$1/"Mysql"/"base.table.sql"
