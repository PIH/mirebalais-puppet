#!/bin/bash
#
# This script is intended to be used for test or reporting instances where the goal is to update an existing
# OpenMRS database, installed via native MySQL, with an updated backup from Percona, deidentifying it, and restarting OpenMRS

# The following variables are expected to be present as environment variables
# If a file exists in the user's home directory named .percona.env, source this in for these variables
if [ -a ~/.percona.env ]; then
  echo "Found a .percona.env file, sourcing"
  source ~/.percona.env
fi

if [ -z "${PERCONA_RESTORE_DIR}" ] || [ -z "${TOMCAT_USER}" ] || [ -z "${TOMCAT_HOME_DIR}" ]; then
  echo "You must have PERCONA_RESTORE_DIR, TOMCAT_USER, and TOMCAT_HOME_DIR environment variables defined to execute this script"
  exit 1
fi

SITE_TO_RESTORE="${1}"
if [ -z "$SITE_TO_RESTORE" ]; then
    echo "You must specify the site to restore as the 1st argument.  eg. haiti/haitihiv"
    exit 1
fi

RESTORE_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
LOG_DIR=${PERCONA_RESTORE_DIR}/${SITE_TO_RESTORE}/logs
LOG_FILE="${LOG_DIR}/restore-log-${RESTORE_DATE}.log"
mkdir -p ${LOG_DIR}
exec > ${LOG_FILE} 2>&1

echo "Starting restoration of OpenMRS DB from $SITE_TO_RESTORE"

echo "Stopping Tomcat"
/etc/init.d/${TOMCAT_USER} stop

echo "Removing configuration checksums and lib cache"
rm -rf ${TOMCAT_HOME_DIR}/.OpenMRS/.openmrs-lib-cache
rm -rf ${TOMCAT_HOME_DIR}/.OpenMRS/configuration_checksums

echo "Restoring Database for ${SITE_TO_RESTORE}"
source ${PERCONA_RESTORE_DIR}/percona-restore.sh "${SITE_TO_RESTORE}"
RESTORE_STATUS=$?

echo "De-identifying Database"
source ${PERCONA_RESTORE_DIR}/deidentify-db.sh
DEIDENTIFY_STATUS=$?

echo "Starting Tomcat"
/etc/init.d/${TOMCAT_USER} start

if [ $RESTORE_STATUS -ne 0 ] ; then
  echo "Percona restore failed"
  mail -s "Percona restore of haitihivtest failed" "${SYSADMIN_EMAIL}" < ${LOG_FILE}
elif [ $DEIDENTIFY_STATUS -ne 0 ] ; then
  echo "Deidentification failed"
  mail -s "Deidentification of haitihivtest failed" "${SYSADMIN_EMAIL}" < ${LOG_FILE}
else
  echo "Haiti HIV Test update successful"
fi
