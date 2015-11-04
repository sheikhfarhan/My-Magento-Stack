#!/bin/sh
#Purpose = Backup of Database 
#Created = 04-11-2015
#Author = Sheikh Farhan
#Version = 2.0

## Place this file in /home/path/under/user
## automatic daily / weekly / monthly backup to S3.
## Add the line below to cronjob (user not root!) for a 4.15am daily run
## 15 4 * * * sh mysqlbackup.sh auto

DATESTAMP=$(date +"%d.%m.%Y-%H%M")
DAY=$(date +"%d")
DAYOFWEEK=$(date +"%A")

#MYSQLROOT=root
#MYSQLPASS=password

S3BUCKET=svr3backups

FILENAME='mysql-'

DATABASE='db01'
# the following line prefixes the backups with the defined directory. it must be blank or end with a /
S3PATH=mysql_backup/
# when running via cron, the PATHs MIGHT be different. If you have a custom/manual MYSQL install, you should set this manually like MYSQLDUMPPATH=/usr/local/mysql/bin/
MYSQLDUMPPATH=
# Destination Directory
DESDIR=~/backup/mysql/

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

echo "Starting backing up the database to a file..."

# dump database
${MYSQLDUMPPATH}mysqldump --skip-opt --single-transaction --quick ${DATABASE} > ${DESDIR}${FILENAME}${DATESTAMP}.sql

echo "Done backing up the database to a file."
echo "Starting compression..."

tar czf ${DESDIR}${FILENAME}${DATESTAMP}.tar.gz ${DESDIR}${FILENAME}${DATESTAMP}.sql

echo "Done compressing the backup file."

# we want at least two backups, two months, two weeks, and two days
echo "Removing old backup (2 ${PERIOD}s ago)..."
s3cmd del --recursive s3://${S3BUCKET}/${S3PATH}previous_${PERIOD}/
echo "Old backup removed."

echo "Moving the backup from past $PERIOD to another folder..."
s3cmd mv --recursive s3://${S3BUCKET}/${S3PATH}${PERIOD}/ s3://${S3BUCKET}/${S3PATH}previous_${PERIOD}/
echo "Past backup moved."

# upload all databases
echo "Uploading the new backup..."
s3cmd put -f ${DESDIR}${FILENAME}${DATESTAMP}.tar.gz s3://${S3BUCKET}/${S3PATH}${PERIOD}/
echo "New backup uploaded."

echo "Removing the cache files..."
# remove databases dump
#Uncomment below if we do not want to keep any files on our server
#rm ${DESDIR}${FILENAME}${DATESTAMP}.sql
#rm ${DESDIR}${FILENAME}${DATESTAMP}.tar.gz
echo "Files removed."
echo "All done."
