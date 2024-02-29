#!/bin/bash
#
# Script to facilitate cleaning up disk space
# Note: care must be taken before running this script on Production servers as we may have PIH EMR debian packages intentionally staged before install

# Output current disk space
df -h

# Remove old debian packages (mainly due to pihemr distribution snapshots)
echo "Removing old debian packages"
apt-get clean

# Remove old maven packages
echo "Removing old maven packages"
rm -fR /root/.m2/repository/org/pih/openmrs

# Output final disk space
df -h
