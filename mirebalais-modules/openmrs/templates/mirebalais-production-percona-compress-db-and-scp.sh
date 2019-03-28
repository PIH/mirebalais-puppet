#!/bin/bash

set -x 

compressedOutput="openmrs.tar"
dirToCompress="/home/percona/backups/openmrs/"
perconaLogs="/home/percona/logs"
openmrsDB="openmrs"
remoteUser="reporting"
remoteHost="192.168.1.217"
backupDir="/home/reporting/percona/backups"
compressedDir="/home/percona/scripts"



compress () {
                tar -cvf ${compressedOutput} ${dirToCompress} &>> ${perconaLogs}/`date +%y%m%d%H%M%S`_compress.log
}

scp_reporting_server () {
                        scp ${compressedDir}/${compressedOutput} ${remoteUser}@${remoteHost}:${backupDir} &>> ${perconaLogs}/`date +%y%m%d%H%M%S`_scp.log

}

delete_percona_files () {
                        rm -rf /home/percona/backups/*
                        rm -rf /home/percona/scripts/openmrs.tar
}

compress
scp_reporting_server
sleep 180
delete_percona_files
