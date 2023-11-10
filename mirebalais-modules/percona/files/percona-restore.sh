#!/bin/bash
#
# Restore Script for downloading a Percona backup and restoring to a MySQL instance
# This script requires docker, azcopy, 7zip to be installed and available

echoWithDate() {
  CURRENT_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
  echo "${CURRENT_DATE}: ${1}"
}

# The following variables are expected to be present as environment variables
# If a file exists in the user's home directory named .percona.env, source this in for these variables
if [ -a ~/.percona.env ]; then
  echoWithDate "Found a .percona.env file, sourcing"
  source ~/.percona.env
fi

if [ -z "${PERCONA_RESTORE_DIR}" ] || [ -z "${PERCONA_BACKUP_PW}" ]; then
  echoWithDate "You must have PERCONA_RESTORE_DIR and PERCONA_BACKUP_PW defined to execute this script"
  exit 1
fi

if [ -z "${BACKUP_SSH_HOST}" ] || [ -z "${BACKUP_SSH_USER}" ] || [ -z "${BACKUP_SSH_DIR}" ]; then
  if [ -z "${AZ_URL}" ] || [ -z "${AZ_SECRET}" ]; then
    echoWithDate "You must have either BACKUP_SSH_HOST and BACKUP_SSH_USER and BACKUP_SSH_DIR or AZ_URL and AZ_SECRET environment variables defined to execute this script"
    exit 1
  fi
fi

# Variables from input arguments
SITE_TO_RESTORE=
MYSQL_DOCKER_CONTAINER=
MYSQL_PORT=
MYSQL_DATA_DIR=
DEIDENTIFY=false
CREATE_PETL_USER=false
RESTART_OPENMRS=false
PRESERVE_TABLES=
MYSQL_BUFFER_POOL_SIZE=128M

for i in "$@"
do
case $i in
    --siteToRestore=*)
      SITE_TO_RESTORE="${i#*=}"
      shift # past argument=value
    ;;
    --mysqlDockerContainerName=*)
      MYSQL_DOCKER_CONTAINER="${i#*=}"
      shift # past argument=value
    ;;
    --mysqlDockerPort=*)
      MYSQL_PORT="${i#*=}"
      shift # past argument=value
    ;;
    --mysqlDockerDataDir=*)
      MYSQL_DATA_DIR="${i#*=}"
      shift # past argument=value
    ;;
    --mysqlBufferPoolSize=*)
      MYSQL_BUFFER_POOL_SIZE="${i#*=}"
      shift # past argument=value
    ;;
    --deidentify=*)
      DEIDENTIFY="${i#*=}"
      shift # past argument=value
    ;;
    --createPetlUser=*)
      CREATE_PETL_USER="${i#*=}"
      shift # past argument=value
    ;;
    --restartOpenmrs=*)
      RESTART_OPENMRS="${i#*=}"
      shift # past argument=value
    ;;
    --preserveTables=*)
      PRESERVE_TABLES="${i#*=}"
      shift # past argument=value
    ;;
    *)
      echoWithDate "Unknown input argument specified"
      exit 1
    ;;
esac
done

if [ -z "$SITE_TO_RESTORE" ]; then
    echoWithDate "You must specify the site to restore"
    exit 1
fi

BASE_DIR="${PERCONA_RESTORE_DIR}/${SITE_TO_RESTORE}"
STATUS_DATA_DIR="${BASE_DIR}/status"
DOWNLOAD_DIR="${BASE_DIR}/percona_downloads"
DATA_DIR="${DOWNLOAD_DIR}/percona_mysql_data"
PRESERVE_TABLES_SQL_FILE="${DOWNLOAD_DIR}/tablesToPreserve.sql"

# Setup working directories and logging
mkdir -p ${STATUS_DATA_DIR}
rm -fR ${DOWNLOAD_DIR}
mkdir -p ${DOWNLOAD_DIR}
mkdir -p ${DATA_DIR}

echoWithDate "Starting restoration of MySQL from $SITE_TO_RESTORE"

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echoWithDate "Restoring into the native MySQL installation"
    MYSQL_DATA_DIR="/var/lib/mysql"
else
    echoWithDate "Restoring into dockerized MySQL installation, container: $MYSQL_DOCKER_CONTAINER"
    if [ -z ${MYSQL_DATA_DIR} ] || [ ${MYSQL_DATA_DIR} == '/' ]; then
      MYSQL_DATA_DIR="${BASE_DIR}/mysql"
      echoWithDate "No MySQL Data Directory specified, defaulting to ${MYSQL_DATA_DIR}"
    else
      echoWithDate "MySQL Data Directory specified: ${MYSQL_DATA_DIR}"
    fi
    if [ -z ${MYSQL_PORT} ]; then
      echoWithDate "MySQL Port is required but has not been specified, exiting"
      exit 1
    fi
fi

retrieve_backup_artifact() {
  if [ -z "${BACKUP_SSH_HOST}" ] || [ -z "${BACKUP_SSH_USER}" ] || [ -z "${BACKUP_SSH_DIR}" ]; then
    echoWithDate "Retreiving ${1} from Azure"
    azcopy copy "${AZ_URL}/${SITE_TO_RESTORE}/percona/${1}?sv=2019-02-02&ss=bfqt&srt=sco&sp=rwdlacup&se=2025-03-29T22:00:00Z&st=2020-03-30T13:00:00Z&spr=https&sig=${AZ_SECRET}" "${DOWNLOAD_DIR}/" --recursive=true --check-md5 FailIfDifferent --from-to=BlobLocal --blob-type Detect;
  else
    echoWithDate "Retreiving ${1} from ${BACKUP_SSH_HOST}"
    scp -v -r ${BACKUP_SSH_USER}@${BACKUP_SSH_HOST}:${BACKUP_SSH_DIR}/* ${DOWNLOAD_DIR}/
  fi
}

# Download backup files and compare to previously downloaded and restored files, and ensure backup is complete

retrieve_backup_artifact "percona.7z.md5"
if [ ! -f ${DOWNLOAD_DIR}/percona.7z.md5 ]; then
    echoWithDate "Missing percona.7z.md5, exiting"
    exit 1
fi
BACKUP_MD5=$(cat ${DOWNLOAD_DIR}/percona.7z.md5)

retrieve_backup_artifact "percona.7z.date"
if [ ! -f ${DOWNLOAD_DIR}/percona.7z.date ]; then
    echoWithDate "Missing percona.7z.date, exiting"
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
    echoWithDate "Current Backup MD5 matches previous backup MD5, skipping restoration"
    rm -fR ${DOWNLOAD_DIR}
    exit 0
fi

if [ "$BACKUP_DATE" = "$LAST_BACKUP_DATE" ]; then
    echoWithDate "Current Backup date matches previous backup date, skipping restoration"
    rm -fR ${DOWNLOAD_DIR}
    exit 0
fi

echoWithDate "Current backup does not match previous backup, downloading and restoring new backup"
retrieve_backup_artifact "percona.7z"

DOWNLOADED_MD5=($(md5sum ${DOWNLOAD_DIR}/percona.7z))
if [ "$DOWNLOADED_MD5" != "$BACKUP_MD5" ]; then
    echoWithDate "Percona MD5 file MD5 of $DOWNLOADED_MD5 does not match the MD5 of the percona.7z backup of $BACKUP_MD5, exiting"
    exit 1
fi

# If we make it here, then we have a new, valid backup file to restore
echoWithDate "Extracting the percona backup"
7za x ${DOWNLOAD_DIR}/percona.7z -p${PERCONA_BACKUP_PW} -y -o${DATA_DIR}

if [ $? -ne 0 ]; then
    echoWithDate "Extraction failed, exiting"
    exit 1
fi

if [ "${RESTART_OPENMRS}" == "true" ]; then
  echoWithDate "Stopping Tomcat"
  service tomcat9 stop

  echoWithDate "Removing configuration checksums and lib cache"
  rm -rf ${TOMCAT_HOME_DIR}/.OpenMRS/.openmrs-lib-cache
  rm -rf ${TOMCAT_HOME_DIR}/.OpenMRS/configuration_checksums
fi

if [ -z "$PRESERVE_TABLES" ]; then
  echoWithDate "No tables configured to preserve"
else
  echoWithDate "Dumping existing contents of ${PRESERVE_TABLES}"
  if [ -z "${MYSQL_DOCKER_CONTAINER}" ]; then
      mysqldump -uroot -p${MYSQL_ROOT_PW} --no-create-info --skip-triggers --extended-insert --lock-tables --quick openmrs ${PRESERVE_TABLES} > ${PRESERVE_TABLES_SQL_FILE}
  else
      docker exec -i ${MYSQL_DOCKER_CONTAINER} mysqldump -uroot -p${MYSQL_ROOT_PW} --no-create-info --skip-triggers --extended-insert --lock-tables --quick openmrs ${PRESERVE_TABLES} > ${PRESERVE_TABLES_SQL_FILE}
  fi
fi

echoWithDate "Stopping the existing MySQL instance"

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echoWithDate "Stopping native mysql"
    service mysql stop
else
    echoWithDate "Re-creating MySQL container: $MYSQL_DOCKER_CONTAINER"
    docker stop $MYSQL_DOCKER_CONTAINER || true
    docker rm $MYSQL_DOCKER_CONTAINER || true
    docker run --name ${MYSQL_DOCKER_CONTAINER} \
      --restart always \
      -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PW} \
      -e TZ=America/New_York \
      -v "${MYSQL_DATA_DIR}:/var/lib/mysql" \
      -p "${MYSQL_PORT}:3306" \
      -d mysql:5.6 \
        --character-set-server=utf8 \
        --collation-server=utf8_general_ci \
        --max_allowed_packet=1G \
        --innodb-buffer-pool-size=${MYSQL_BUFFER_POOL_SIZE}
    sleep 10
    echoWithDate "Stopping MySQL container"
    docker stop $MYSQL_DOCKER_CONTAINER || true
fi

echoWithDate "Re-creating existing data directory: ${MYSQL_DATA_DIR}"
rm -fR ${MYSQL_DATA_DIR}
mkdir -p ${MYSQL_DATA_DIR}

echoWithDate "Moving the percona backup contents into the MySQL data directory"
docker run --name percona --rm \
    -v ${DATA_DIR}:/opt/backup \
    -v ${MYSQL_DATA_DIR}:/var/lib/mysql \
    partnersinhealth/percona-0.1-4 \
    innobackupex --move-back --datadir=/var/lib/mysql /opt/backup

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echoWithDate "Changing permissions of data directory"
    chown -R mysql:mysql ${MYSQL_DATA_DIR}
    echoWithDate "Starting native mysql"
    /etc/init.d/mysql start
    sleep 10
    echoWithDate "Running mysql check"
    /usr/bin/mysqlcheck --auto-repair --check --all-databases -ubackup -p${PERCONA_BACKUP_PW}
else
    echoWithDate "Changing permissions of data directory"
    chown -R 999:999 ${MYSQL_DATA_DIR}
    echoWithDate "Starting MySQL container: $MYSQL_DOCKER_CONTAINER"
    docker start $MYSQL_DOCKER_CONTAINER
    sleep 10
    echoWithDate "Running mysql check"
    docker exec -i $MYSQL_DOCKER_CONTAINER sh -c "/usr/bin/mysqlcheck --auto-repair --check --all-databases -ubackup -p'${PERCONA_BACKUP_PW}'"
fi

if [ $? -eq 0 ]; then
    echoWithDate "Backup restored successfully and all tables are correct"
else
    echoWithDate "Mysql check failed, exiting"
    exit 1
fi

echoWithDate "Adding backup information to the database"
BACKUP_DATE=$(cat ${DOWNLOAD_DIR}/percona.7z.date)
CURRENT_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
BACKUP_DATE_SQL="insert into global_property (property, property_value, uuid) values ('percona_backup_date', '${BACKUP_DATE}', uuid());"
RESTORE_DATE_SQL="insert into global_property (property, property_value, uuid) values ('percona_restore_date', '${CURRENT_DATE}', uuid());"
if [ -z "${MYSQL_DOCKER_CONTAINER}" ]; then
    mysql -uroot -p${MYSQL_ROOT_PW} -e "${BACKUP_DATE_SQL} ${RESTORE_DATE_SQL}" openmrs
else
    docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -u root -p${MYSQL_ROOT_PW} -e "${BACKUP_DATE_SQL} ${RESTORE_DATE_SQL}" openmrs
fi
if [ $? -eq 0 ]; then
    echoWithDate "Backup information added successfully"
else
  echoWithDate "An error occurred while adding backup information to the database"
  exit 1
fi

if [ -z "$PRESERVE_TABLES" ]; then
  echoWithDate "No tables configured to preserve"
else
  echoWithDate "Restoring previously dumped contents of ${PRESERVE_TABLES}"
  if [ -z "${MYSQL_DOCKER_CONTAINER}" ]; then
    for TABLE_NAME in ${PRESERVE_TABLES}; do
        echo "Deleting from ${TABLE_NAME}"
        mysql -u root -p${MYSQL_ROOT_PW} openmrs -e "delete * from ${TABLE_NAME};"
    done
    mysql -uroot -p${MYSQL_ROOT_PW} openmrs < ${PRESERVE_TABLES_SQL_FILE}
  else
    for TABLE_NAME in ${PRESERVE_TABLES}; do
        echo "Deleting from ${TABLE_NAME}"
        docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -u root -p${MYSQL_ROOT_PW} openmrs -e "delete * from ${TABLE_NAME};"
    done
    docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -uroot -p${MYSQL_ROOT_PW} openmrs < ${PRESERVE_TABLES_SQL_FILE}
  fi
fi

if [ "${DEIDENTIFY}" == "true" ]; then
  echoWithDate "De-identifying the database"
  if [ -z "${MYSQL_DOCKER_CONTAINER}" ]; then
      echoWithDate "De-identifying the native MySQL installation"
      mysql -uroot -p${MYSQL_ROOT_PW} openmrs < ${PERCONA_RESTORE_DIR}/deidentify-db.sql
  else
      echoWithDate "De-identifying dockerized MySQL installation, container: ${MYSQL_DOCKER_CONTAINER}"
      docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -uroot -p${MYSQL_ROOT_PW} openmrs < ${PERCONA_RESTORE_DIR}/deidentify-db.sql
  fi
  if [ $? -eq 0 ]; then
      echoWithDate "De-identification successful"
  else
    echoWithDate "An error occurred during de-identification"
    exit 1
  fi
fi

if [ "${CREATE_PETL_USER}" == "true" ]; then
  echoWithDate "Creating PETL user"

  if [ -z "${PETL_MYSQL_USER}" ] || [ -z "${PETL_MYSQL_PASSWORD}" ] || [ -z "${PETL_OPENMRS_DB}" ]; then
    echoWithDate "You must have PETL_MYSQL_USER, PETL_MYSQL_PASSWORD, PETL_OPENMRS_DB environment variables defined to create petl user"
    exit 1
  fi

  SELECT_USER_SQL="select count(*) from mysql.user where user = '${PETL_MYSQL_USER}' and host = '%';"
  CREATE_USER_SQL="create user '${PETL_MYSQL_USER}'@'%' identified by '${PETL_MYSQL_PASSWORD}';";
  GRANT_USER_SQL="grant all privileges on ${PETL_OPENMRS_DB}.* to '${PETL_MYSQL_USER}'@'%';"

  if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
      echoWithDate "Creating PETL DB user is only currently supported in Docker, exiting"
      exit 1
  else
      echoWithDate "Ensuring MySQL user ${PETL_MYSQL_USER}'@'%' in container ${MYSQL_DOCKER_CONTAINER}"
      EXISTING_USERS=$(docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -u root -p${MYSQL_ROOT_PW} -N -e "${SELECT_USER_SQL}")
      if [ "${EXISTING_USERS}" -eq 0 ]; then
        echoWithDate "No user found, creating"
        docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -u root -p${MYSQL_ROOT_PW} -e "${CREATE_USER_SQL} ${GRANT_USER_SQL}"
        if [ $? -eq 0 ]; then
          echoWithDate "Create user successful"
        else
          echoWithDate "Create user failed, exiting"
          exit 1
        fi
      else
        echoWithDate "User already exists, not re-creating"
      fi
  fi

fi

if [ $? -eq 0 ]; then
  # If the script makes it here, copy the latest MD5 and date files into the status directory and delete downloaded files
  echoWithDate "Backup restoration successful, copying most recent backup date and md5 files into status directory"
  cp ${DOWNLOAD_DIR}/percona.7z.date ${STATUS_DATA_DIR}/
  cp ${DOWNLOAD_DIR}/percona.7z.md5 ${STATUS_DATA_DIR}/
  rm -fR ${DOWNLOAD_DIR}
  echoWithDate "Successfully completed"
else
  echoWithDate "Restoration failed"
  exit 1
fi

if [ "${RESTART_OPENMRS}" == "true" ]; then
  echoWithDate "Starting Tomcat"
  service tomcat9 start
fi
