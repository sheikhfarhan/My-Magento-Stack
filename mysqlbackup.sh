#!/bin/sh
#Purpose = Backup of Database
#Created on 03-11-2015
#Author = Sheikh Farhan
#Version 5.0

## Create and Place this file in /home/path/under/user
## Run a cronjob under user not root!
## automatic daily / weekly / monthly backup to S3 at 0415 daily
## 15 4 * * * sh mysqlbackup.sh auto

DATESTAMP=$(date +"%d.%m.%Y-%H%M")
DAY=$(date +"%d")
DAYOFWEEK=$(date +"%A")

# Variables #

#MYSQLROOT= # use =root if want to backup all
#MYSQLPASS= # if use =root above, then can leave this empty, as password is saved at ~/.my.cnf file

DATABASE=	'db01'  # use '--all-databases' if want to backup all
FILENAME=	mysql-${DATESTAMP}
DESDIR=		/home/gandalf/backup

# Name of our S3 Buckets

S3BUCKET=	svr3backups

# the following line prefixes the backups with the defined directory. 
#it must be blank or end with a /

S3PATH=mysql/

# when running via cron, the PATHs MIGHT be different. 
#If have a custom/manual MYSQL install, to set this manually like MYSQLDUMPPATH=/usr/local/mysql/bin/
#MYSQLDUMPPATH=

echo "Starting backing up the database to a file..."

# dump database
${MYSQLDUMPPATH}mysqldump --skip-opt --single-transaction --quick ${DATABASE} > ${DESDIR}/${FILENAME}.sql

echo "Done backing up the database to a file."

echo "Starting compression..."

gzip -9 ${DESDIR}/${FILENAME}.sql

echo "Done compressing the backup file."

# Configure Period

PERIOD=${1-day}
if [ ${PERIOD} = "auto" ]; then
	if [ ${DAY} = "01" ]; then
        	PERIOD=month
	elif [ ${DAYOFWEEK} = "Sunday" ]; then
        	PERIOD=week
	else
       		PERIOD=day
	fi	
fi

echo "Selected period: $PERIOD."

# we want at least two backups, two months, two weeks, and two days
echo "Removing old backup (2 ${PERIOD}s ago)..."
s3cmd del --recursive s3://${S3BUCKET}/${S3PATH}previous_${PERIOD}/
echo "Old backup removed."

echo "Moving the backup from past $PERIOD to another folder..."
s3cmd mv --recursive s3://${S3BUCKET}/${S3PATH}${PERIOD}/ s3://${S3BUCKET}/${S3PATH}previous_${PERIOD}/
echo "Past backup moved."

# upload all databases to S3
echo "Uploading the new backup..."
s3cmd put -f ${DESDIR}/${FILENAME}.sql.gz s3://${S3BUCKET}/${S3PATH}${PERIOD}/
echo "New backup uploaded."

echo "Removing the cache files..."

#Comment below if we wish to keep backups on server
# To remove databases dump

rm ${DESDIR}/${FILENAME}.sql.gz
echo "Files removed."
echo "All done."

