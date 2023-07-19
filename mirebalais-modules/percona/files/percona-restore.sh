#!/bin/bash
#
# Restore Script for downloading a Percona backup and restoring to a MySQL instance
# This script requires docker, azcopy, 7zip to be installed and available

# The following variables are expected to be present as environment variables
# If a file exists in the user's home directory named .percona.env, source this in for these variables
if [ -a ~/.percona.env ]; then
  echo "Found a .percona.env file, sourcing"
  source ~/.percona.env
fi

if [ -z "${PERCONA_RESTORE_DIR}" ] || [ -z "${PERCONA_BACKUP_PW}" ] || [ -z "${AZ_URL}" ] || [ -z "${AZ_SECRET}" ]; then
  echo "You must have PERCONA_RESTORE_DIR, PERCONA_BACKUP_PW, AZ_URL, and AZ_SECRET environment variables defined to execute this script"
  exit 1
fi

# Variables from input arguments
SITE_TO_RESTORE="${1}"
MYSQL_DOCKER_CONTAINER="${2}"
MYSQL_DATA_DIR="${3}"

if [ -z "$SITE_TO_RESTORE" ]; then
    echo "You must specify the site to restore as the 1st argument.  eg. haiti/hinche"
    exit 1
fi
echo "Starting restoration of MySQL from $SITE_TO_RESTORE"

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echo "Restoring into the native MySQL installation"
    MYSQL_DATA_DIR="/var/lib/mysql"
else
    echo "Restoring into dockerized MySQL installation, container: $MYSQL_DOCKER_CONTAINER"
fi

if [ ! -d $MYSQL_DATA_DIR ]; then
    echo "You must specify the MySQL data directory if you specify the MySQL Docker container.  This must exist."
    exit 1
fi
echo "Restoring into MySQL data directory: $MYSQL_DATA_DIR"

# Variables
BASE_DIR="${PERCONA_RESTORE_DIR}/${SITE_TO_RESTORE}"
STATUS_DATA_DIR="${BASE_DIR}/status"
DOWNLOAD_DIR="${BASE_DIR}/percona_downloads"
DATA_DIR="${DOWNLOAD_DIR}/percona_mysql_data"
RESTORE_DATE=$(date '+%Y-%m-%d-%H-%M-%S')

# Setup working directories
mkdir -p ${STATUS_DATA_DIR}
rm -fR ${DOWNLOAD_DIR}
mkdir -p ${DOWNLOAD_DIR}
mkdir -p ${DATA_DIR}

copy_from_azure_percona() {
    azcopy copy "${AZ_URL}/${SITE_TO_RESTORE}/percona/${1}?sv=2019-02-02&ss=bfqt&srt=sco&sp=rwdlacup&se=2025-03-29T22:00:00Z&st=2020-03-30T13:00:00Z&spr=https&sig=${AZ_SECRET}" "${DOWNLOAD_DIR}/" --recursive=true --check-md5 FailIfDifferent --from-to=BlobLocal --blob-type Detect;
}

# Download backup files from Azure and compare to previously downloaded and restored files, and ensure backup is complete

copy_from_azure_percona "percona.7z.md5"
if [ ! -f ${DOWNLOAD_DIR}/percona.7z.md5 ]; then
    echo "Missing percona.7z.md5, exiting"
    exit 1
fi
BACKUP_MD5=$(cat ${DOWNLOAD_DIR}/percona.7z.md5)

copy_from_azure_percona "percona.7z.date"
if [ ! -f ${DOWNLOAD_DIR}/percona.7z.date ]; then
    echo "Missing percona.7z.date, exiting"
    exit 1
fi
BACKUP_DATE=$(cat ${DOWNLOAD_DIR}/percona.7z.date)

LAST_BACKUP_MD5=
if [ -f ${STATUS_DATA_DIR}/percona.7z.md5 ]; then
    LAST_BACKUP_MD5=$(cat ${STATUS_DATA_DIR}/percona.7z.md5)
fi

LAST_BACKUP_DATE=
if [ -f ${STATUS_DATA_DIR}/percona.7z.date ]; then
    LAST_BACKUP_DATE=$(cat ${STATUS_DATA_DIR}/percona.7z.date)
fi

if [ "$BACKUP_MD5" = "$LAST_BACKUP_MD5" ]; then
    echo "Current Backup MD5 matches previous backup MD5, skipping restoration"
    exit 0
fi

if [ "$BACKUP_DATE" = "$LAST_BACKUP_DATE" ]; then
    echo "Current Backup MD5 matches previous backup MD5, skipping restoration"
    exit 0
fi

echo "Current backup does not match previous backup, downloading and restoring new backup"
copy_from_azure_percona "percona.7z"

DOWNLOADED_MD5=($(md5sum ${DOWNLOAD_DIR}/percona.7z))
if [ "$DOWNLOADED_MD5" != "$BACKUP_MD5" ]; then
    echo "Percona MD5 file MD5 of $DOWNLOADED_MD5 does not match the MD5 of the percona.7z backup of $BACKUP_MD5, exiting"
    exit 1
fi

# If we make it here, then we have a new, valid backup file to restore
echo "Extracting the percona backup"
7za x ${DOWNLOAD_DIR}/percona.7z -p${PERCONA_BACKUP_PW} -y -o${DATA_DIR}

if [ $? -ne 0 ]; then
    echo "Extraction failed, exiting"
    exit 1
fi

echo "Stopping the existing MySQL instance"

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echo "Stopping native mysql"
    service mysql stop
else
    echo "Stopping MySQL container: $MYSQL_DOCKER_CONTAINER"
    docker stop $MYSQL_DOCKER_CONTAINER || true
fi

echo "Removing existing data directory contents"
rm -fr ${MYSQL_DATA_DIR}/*

echo "Copying the percona backup contents into the MySQL data directory"
docker run --name percona --rm \
    -v ${DATA_DIR}:/opt/backup \
    -v ${MYSQL_DATA_DIR}:/var/lib/mysql \
    partnersinhealth/percona-0.1-4 \
    innobackupex --copy-back --datadir=/var/lib/mysql /opt/backup

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echo "Changing permissions of data directory"
    chown -R mysql:mysql ${MYSQL_DATA_DIR}
    echo "Starting native mysql"
    /etc/init.d/mysql start
    sleep 10
    echo "Running mysql check"
    /usr/bin/mysqlcheck --auto-repair --check --all-databases -ubackup -p'${PERCONA_BACKUP_PW}'
else
    echo "Changing permissions of data directory"
    chown -R 999:999 ${MYSQL_DATA_DIR}
    echo "Starting MySQL container: $MYSQL_DOCKER_CONTAINER"
    docker start $MYSQL_DOCKER_CONTAINER
    sleep 10
    echo "Running mysql check"
    docker exec -i $MYSQL_DOCKER_CONTAINER sh -c "exec mysqlcheck --auto-repair --check --all-databases -ubackup -p'${PERCONA_BACKUP_PW}'"
fi

if [ $? -eq 0 ]; then
        echo "Backup restored successfully and all tables are correct"

        # Once backup restored successfully, copy the latest MD5 and date files into the status directory and delete downloaded files
        echo "Backup restoration successful, copying most recent backup date and md5 files into status directory"
        cp ${DOWNLOAD_DIR}/percona.7z.date ${STATUS_DATA_DIR}/
        cp ${DOWNLOAD_DIR}/percona.7z.md5 ${STATUS_DATA_DIR}/
        rm -fR ${DOWNLOAD_DIR}
        echo "Successfully completed"

else
        echo "Mysql check failed, exiting"
        exit 1
fi
