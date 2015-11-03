#!/bin/sh
#Purpose = Backup of Website 
#Created = 03-11-2015
#Author = Sheikh Farhan
#Version = 3.0

## Place this file in /home/path/under/user
## automatic daily / weekly / monthly backup to S3.
## Add the line below to cronjob (user not root!) for a 4am daily run
## 0 4 * * * sh webbackup.sh auto

# WEBSITE BACKUP

DATESTAMP=	$(date +"%d.%m.%Y-%H%M")
DAY=		$(date +"%d")
DAYOFWEEK=	$(date +"%A")

FILENAME=	website-$DATESTAMP.tar.gz   # Backup file name format
SRCDIR=		/var/www/bazaar22.com/public     # Location / Source of Backup
DESDIR=		/home/gandalf/backup      # Destination Directory (create this dir first!)

S3BUCKET=	svr3backups    #bucket name must be exact as per our S3
S3PATH=		website/

# Save and Tar Website Folders and Files 
# Not including cache,sessions and tmp files
# Should be easier to do an exlude.txt.. hmm..

tar -cpzf ${DESDIR}/${FILENAME} $SRCDIR --exclude='/var/www/bazaar22.com/public/media/catalog/product/cache' --exclude='/var/www/bazaar22.com/public/var/cache' --exclude='/var/www/bazaar22.com/public/var/session' --exclude='/var/www/bazaar22.com/public/var/tmp' --exclude='/var/www/bazaar22.com/public/var/package/tmp' 

echo "Done backing up and compressing the website to a file."

# Configure the Period

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

# At least two backups, two months, two weeks, and two days

echo "Removing old backup (2 ${PERIOD}s ago)..."
s3cmd del --recursive s3://${S3BUCKET}/${S3PATH}previous_${PERIOD}/
echo "Old backup removed."

echo "Moving the backup from past $PERIOD to another folder..."
s3cmd mv --recursive s3://${S3BUCKET}/${S3PATH}${PERIOD}/ s3://${S3BUCKET}/${S3PATH}previous_${PERIOD}/
echo "Past backup moved."

## Upload to S3 Bucket
echo "Uploading the new backup to S3..."
s3cmd put -f ${DESDIR}/${FILENAME} s3://${S3BUCKET}/${S3PATH}${PERIOD}/
echo "New backup uploaded succesfully to S3."

# to do if fail output to log file or email?

echo "Removing the cache files..."

#Comment below if we wish to keep backups on server

rm ${DESDIR}/${FILENAME}
echo "Files removed."
echo "All done."

