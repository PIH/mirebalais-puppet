#! /bin/bash

rm -fR /etc/puppet
mkdir /etc/puppet
cp -a /etc/mirebalais-puppet/* /etc/puppet/
pushd /etc/puppet
./install.sh
popd