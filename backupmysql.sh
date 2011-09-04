#! /bin/bash

# Set a value that we can use for a datestamp
DATE=`date +%Y-%m-%d`

# Our Base backup directory
BASEBACKUP="/home/ec2-user/backup/mysql"

ec2-describe-instances | egrep ^INSTANCE | cut -f5 > /home/ec2-user/scripts/servers-mysql.txt

for SERVER in `cat ~/scripts/servers-mysql.txt`
do
    echo ""
    echo ""
    echo ""
    echo "Dumping database from server: $SERVER"
    echo '===================================================='
    for DATABASE in `echo 'show databases' | mysql -h$SERVER | sed '1d'`
	do
	        # This is where we throw our backups.
	        FILEDIR="$BASEBACKUP/$SERVER"
	        # Test to see if our backup directory exists.
	        # If not, create it.
	        if [ ! -d $FILEDIR ]
	        then
	                mkdir -p $FILEDIR
	        fi
	
		echo  "Deleting previous backup for database: $DATABASE"
		rm -f $FILEDIR/$DATABASE.sql

	        echo -n "Exporting database: $DATABASE"
        	mysqldump --max_allowed_packet=500M --hex-blob --extended-insert --single-transaction -h$SERVER -Q --add-drop-table $DATABASE > $FILEDIR/$DATABASE.sql
        	echo "      ......[ Done ] "
	done
done

# Backup to s3
export AWS_ACCESS_KEY_ID=<Your Key>
export AWS_SECRET_ACCESS_KEY=<Your Key>
export PASSPHRASE=<Your Pass Phrase>

echo "Doing full Duplicity Backup"
duplicity --full-if-older-than 7D --archive-dir=/home/ec2-user/.cache/duplicity/ --s3-european-buckets --s3-use-new-style --encrypt-key=<Your Encrypt Key> --sign-key=<Your Encrypt Key> /home/ec2-user/backup/mysql s3+http://solidstategroup-a1backup/mysql

# Remove older files from s3
duplicity remove-older-than 21D --s3-european-buckets --s3-use-new-style --encrypt-key=<Your Encrypt Key> --sign-key=<Your Encrypt Key> s3+http://solidstategroup-a1backup/mysql --force

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export PASSPHRASE=
