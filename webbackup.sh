#!/bin/sh
#Purpose = Backup of Website 
#Created = 04-11-2015
#Author = Sheikh Farhan
#Version = 2.0

## Place this file in /home/path/under/user
## automatic daily / weekly / monthly backup to S3.
## Add the line below to cronjob (user not root!) for a 4am daily run
## 0 4 * * * sh webbackup.sh auto

DATESTAMP=$(date +"%d.%m.%Y-%H%M")
DAY=$(date +"%d")
DAYOFWEEK=$(date +"%A")

S3BUCKET=svr3backups

FILENAME='website-'
# the following line prefixes the backups with the defined directory. 
#it must be blank or end with a /
S3PATH=website_backup/
# Destination Directory
DESDIR=~/backup/website/
# Source Directory
SRCDIR=/var/www/bazaar22.com/public

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

# Save and Tar Website Folders and Files 
# Not including cache,sessions and tmp files
# Should be easier to do an exlude.txt.. hmm..

tar -cpzf ${DESDIR}${FILENAME}${DATESTAMP}.tar.gz --exclude='/var/www/bazaar22.com/public/media/catalog/product/cache' --exclude='/var/www/bazaar22.com/public/var/cache' --exclude='/var/www/bazaar22.com/public/var/session' --exclude='/var/www/bazaar22.com/public/var/tmp' --exclude='/var/www/bazaar22.com/public/var/package/tmp' ${SRCDIR}

echo "Done backing up and compressing the website to a file."

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
#rm ${DESDIR}${FILENAME}${DATESTAMP}.tar.gz
echo "Files removed."
echo "All done."
