#!/bin/bash
#
# This script is intended to be used to create a PETL user in a dockerized MySQL container created by Percona

if [ -a ~/.percona.env ]; then
  echo "Found a .percona.env file, sourcing"
  source ~/.percona.env
fi

if [ -z "${PETL_MYSQL_USER}" ] || [ -z "${PETL_MYSQL_USER_IP}" ] || [ -z "${PETL_MYSQL_PASSWORD}" ] || [ -z "${PETL_OPENMRS_DB}" ]; then
  echo "You must have PETL_MYSQL_USER, PETL_MYSQL_USER_IP, PETL_MYSQL_PASSWORD, PETL_OPENMRS_DB environment variables defined to execute this script"
  exit 1
fi

# Variables from input arguments
MYSQL_DOCKER_CONTAINER="${1}"
SELECT_USER_SQL="select count(*) from mysql.user where user = '${PETL_MYSQL_USER}' and host = '${PETL_MYSQL_USER_IP}';"
CREATE_USER_SQL="create user ${PETL_MYSQL_USER}'@'${PETL_MYSQL_USER_IP}' identified by '${PETL_MYSQL_PASSWORD}';";
GRANT_USER_SQL="grant all privileges on ${PETL_OPENMRS_DB}.* to ${PETL_MYSQL_USER}'@'${PETL_MYSQL_USER_IP}';"

if [ -z "$MYSQL_DOCKER_CONTAINER" ]; then
    echo "Creating PETL DB user is only currently supported in Docker, exiting"
    exit 1
else
    echo "Ensuring MySQL user ${PETL_MYSQL_USER}'@'${PETL_MYSQL_USER_IP}' in container ${MYSQL_DOCKER_CONTAINER}"
    EXISTING_USERS=$(docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -u root -p${MYSQL_ROOT_PW} -N -e "${SELECT_USER_SQL}")
    if [ "${EXISTING_USERS}" -eq 0 ]; then
      echo "No user found, creating"
      docker exec -i ${MYSQL_DOCKER_CONTAINER} mysql -u root -p${MYSQL_ROOT_PW} -e "${CREATE_USER_SQL} ${GRANT_USER_SQL}"
    else
      echo "User already exists, not re-creating"
    fi
fi

if [ $? -eq 0 ]; then
  echo "Create user successful"
else
  echo "Create user failed, exiting"
  exit 1
fi
