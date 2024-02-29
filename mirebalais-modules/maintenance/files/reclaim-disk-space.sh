#!/bin/bash
#
# Script to facilitate cleaning up disk space

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
