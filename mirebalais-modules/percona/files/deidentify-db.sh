#!/bin/bash
#
# De-identifies the MySQL database given

# The following variables are expected to be present as environment variables
# If a file exists in the user's home directory named .percona.env, source this in for these variables
if [ -a ~/.percona.env ]; then
  echo "Found a .percona.env file, sourcing"
  source ~/.percona.env
fi

if [ -z "${PERCONA_RESTORE_DIR}" ] || [ -z "${PERCONA_BACKUP_PW}" ]; then
  echo "You must have PERCONA_RESTORE_DIR and PERCONA_BACKUP_PW variables defined to execute this script"
  exit 1
fi

# Variables from input arguments
MYSQL_DOCKER_CONTAINER="${1}"
if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echo "De-identifying the native MySQL installation"
    mysql -ubackup -p'${PERCONA_BACKUP_PW}' openmrs < ${PERCONA_RESTORE_DIR}/deidentify-db.sql
else
    echo "De-identifying dockerized MySQL installation, container: $MYSQL_DOCKER_CONTAINER"
    docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -ubackup -p'${PERCONA_BACKUP_PW}' openmrs < ${PERCONA_RESTORE_DIR}/deidentify-db.sql
fi

if [ $? -eq 0 ]; then
  echo "De-identification successful"
else
  echo "Deidentification failed, exiting"
  exit 1
fi