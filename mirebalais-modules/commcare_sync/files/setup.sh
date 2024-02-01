#!/bin/bash
#
# Set up CommCare sync

# Default variables
COMMCARE_SYNC_HOME_DIR="/home/commcare_sync"
COMMCARE_SYNC_CODE_DIR="${COMMCARE_SYNC_HOME_DIR}/code"
COMMCARE_SYNC_LOG_FILE="${COMMCARE_SYNC_HOME_DIR}/commcare_sync.log"

# Default variables can be overridden via a .commcare_sync.env file in the current working directory
if [ -a .commcare_sync.env ]; then
  source .commcare_sync.env
fi

# set up logging to file
exec > ${COMMCARE_SYNC_LOG_FILE} 2>&1

echoWithDate() {
  CURRENT_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
  echo "${CURRENT_DATE}: ${1}"
}

echoWithDate "Removing existing containers"
docker-compose -f ${COMMCARE_SYNC_CODE_DIR}/docker-compose.yml down

echoWithDate "Initializing new containers"
docker-compose -f ${COMMCARE_SYNC_CODE_DIR}/docker-compose.yml up -d

echoWithDate "Executing migrations"
docker-compose -f ${COMMCARE_SYNC_CODE_DIR}/docker-compose.yml exec -T web python manage.py migrate

echoWithDate "CommCare Sync Setup Completed"