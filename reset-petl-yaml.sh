#!/bin/bash

cd /etc/puppet
chmod 755 replace-petltest-vars.sh
git stash
rm -rf /tmp/petl_configuration