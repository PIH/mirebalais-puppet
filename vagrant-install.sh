#! /bin/bash

rm -fR /etc/puppet
mkdir /etc/puppet
cp -a /etc/mirebalais-puppet/* /etc/puppet/
pushd /etc/puppet
./install.sh
#./puppet-apply.sh site
popd
tail -f /var/lib/tomcat7/logs/catalina.out