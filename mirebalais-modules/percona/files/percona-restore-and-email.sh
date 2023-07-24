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

if [ -z "${PERCONA_RESTORE_DIR}" ]; then
  echo "You must have PERCONA_RESTORE_DIR variable defined to execute this script"
  exit 1
fi

INPUT_ARGUMENTS="$@"

# Variables from input arguments
SITE_TO_RESTORE=

for i in "$@"
do
case $i in
    --siteToRestore=*)
      SITE_TO_RESTORE="${i#*=}"
      shift # past argument=value
    ;;
    *)
    ;;
esac
done

if [ -z "$SITE_TO_RESTORE" ]; then
    echo "You must specify the site to restore"
    exit 1
fi

LOG_DIR="${PERCONA_RESTORE_DIR}/${SITE_TO_RESTORE}/logs"
RESTORE_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
LOG_FILE="${LOG_DIR}/restore-log-${RESTORE_DATE}.log"

mkdir -p ${LOG_DIR}
exec > ${LOG_FILE} 2>&1

/bin/bash ${PERCONA_RESTORE_DIR}/percona-restore.sh ${INPUT_ARGUMENTS}
if [ $? -eq 0 ]; then
  echo "Restoration of ${SITE_TO_RESTORE} successful"
else
  echo "Percona restore failed"
  if [ ! -z "${SYSADMIN_EMAIL}" ]; then
    mail -s "Percona restore of ${SITE_TO_RESTORE} failed" "${SYSADMIN_EMAIL}" < ${LOG_FILE}
  fi
  exit 1
fi
