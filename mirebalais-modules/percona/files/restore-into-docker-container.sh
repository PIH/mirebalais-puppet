#!/bin/bash
#
# This script is intended to be used for test or reporting instances where the goal is load a MySQL docker container
# with a particular Percona backup.  This will recreate any Docker container that already exists with the same name
# This will also de-identify the database after it is restored.

# The following variables are expected to be present as environment variables
# If a file exists in the user's home directory named .percona.env, source this in for these variables
if [ -a ~/.percona.env ]; then
  echo "Found a .percona.env file, sourcing"
  source ~/.percona.env
fi

if [ -z "${PERCONA_RESTORE_DIR}" ] || [ -z "${MYSQL_ROOT_PW}" ]; then
  echo "You must have PERCONA_RESTORE_DIR, MYSQL_ROOT_PW environment variables defined to execute this script"
  exit 1
fi

SITE_TO_RESTORE="${1}"
DOCKER_PORT="${2}"
if [ -z "$SITE_TO_RESTORE" ]; then
    echo "You must specify the site to restore as the 1st argument.  eg. haiti/haitihiv"
    exit 1
fi

if [ -z "$DOCKER_PORT" ]; then
    echo "You must specify the Docker MySQL port as the 2nd argument.  eg. 3310"
    exit 1
fi

# Replace the "/" is the site to restore with underscore to use for things like the Docker container name
NORMALIZED_SITE_NAME=${SITE_TO_RESTORE/\//_}
DOCKER_CONTAINER_NAME="${NORMALIZED_SITE_NAME}_mysql"
DOCKER_DATA_DIR=${PERCONA_RESTORE_DIR}/${SITE_TO_RESTORE}/mysql

RESTORE_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
LOG_DIR=${PERCONA_RESTORE_DIR}/${SITE_TO_RESTORE}/logs
LOG_FILE="${LOG_DIR}/restore-log-${RESTORE_DATE}.log"
mkdir -p ${LOG_DIR}
exec > ${LOG_FILE} 2>&1

echo "Loading backup from $SITE_TO_RESTORE into docker container ${DOCKER_CONTAINER_NAME}"

echo "Ensuring MySQL data directory exists"
mkdir -p ${DOCKER_DATA_DIR}

echo "Checking for the existence of Docker container named ${DOCKER_CONTAINER_NAME}"
if [ ! "$(docker ps -a -q -f name=${DOCKER_CONTAINER_NAME})" ]; then
    echo "A Docker container named ${DOCKER_CONTAINER_NAME} does not exist"
    if [ "$(docker ps -aq -f status=exited -f name=${DOCKER_CONTAINER_NAME})" ]; then
      echo "An exited container exists, removing it"
      docker rm ${DOCKER_CONTAINER_NAME}
    fi
    echo "Creating a new Docker container"
    docker run --name ${DOCKER_CONTAINER_NAME} \
      -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PW} \
      -v "${DOCKER_DATA_DIR}:/var/lib/mysql" \
      -p "${DOCKER_PORT}:3306" \
      -d mysql:5.6 \
        --character-set-server=utf8 \
        --collation-server=utf8_general_ci \
        --max_allowed_packet=1G \
        --innodb-buffer-pool-size=2G
else
  echo "Docker container already exists, not recreating"
fi

sleep 10

echo "Restoring Database for ${SITE_TO_RESTORE}"
/bin/bash ${PERCONA_RESTORE_DIR}/percona-restore.sh "${SITE_TO_RESTORE}" "${DOCKER_CONTAINER_NAME}" "${DOCKER_DATA_DIR}"

RESTORE_STATUS=$?
sleep 10
echo "De-identifying Database"
/bin/bash ${PERCONA_RESTORE_DIR}/deidentify-db.sh
DEIDENTIFY_STATUS=$?

if [ $RESTORE_STATUS -ne 0 ] ; then
  echo "Percona restore failed"
  mail -s "Percona restore of ${SITE_TO_RESTORE} failed" "${SYSADMIN_EMAIL}" < ${LOG_FILE}
elif [ $DEIDENTIFY_STATUS -ne 0 ] ; then
  echo "Deidentification failed"
  mail -s "Deidentification of ${SITE_TO_RESTORE} failed" "${SYSADMIN_EMAIL}" < ${LOG_FILE}
else
  echo "Restoration of ${SITE_TO_RESTORE} successful"
fi
