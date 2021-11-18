#!/bin/bash

cd /etc/puppet
chmod 755 replace-petltest-vars.sh
git stash
git pull
rm -rf /tmp/petl_configuration