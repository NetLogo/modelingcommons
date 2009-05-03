#!/bin/sh

BACKUP_ROOT="/home/reuven/nlcommons/backups"
STEM="nlcommons"
YEAR=`/bin/date +'%Y'`
MONTH=`/bin/date +'%m'`
DAY=`/bin/date +'%d'`

DIRECTORY="$BACKUP_ROOT/$YEAR/$MONTH/$DAY"

/bin/mkdir -p $DIRECTORY

# Backup development
/usr/local/pgsql/bin/pg_dump -O  -x  -d -U reuven nlcommons_development | /bin/gzip --best --verbose >  $DIRECTORY/$STEM-development-db.gz
