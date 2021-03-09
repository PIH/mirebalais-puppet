#! /bin/bash

# hack to make sure we have ruby1.9 installed instead of ruby1.8
if [ $(lsb_release -rs) == "14.04" ]
then
cp -r Gemfile1404 Gemfile
apt-get remove ruby1.8
apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 \
build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

gem install bundler --no-ri --no-rdoc

bundle

fi

if [ $(lsb_release -rs) == "16.04" ] || [ $(lsb_release -rs) == "20.04" ]
then
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe'
apt-get -y update
apt-get -y upgrade
cp -r Gemfile1604 Gemfile
sudo apt-get -y install build-essential ruby-full

gem install bundler --no-ri --no-rdoc

bundle
bundle update

# hack to remove the problematic ec2 fact, see: https://pihemr.atlassian.net/browse/UHM-3869
rm -f /var/lib/gems/2.3.0/gems/facter-2.5.7/lib/facter/util/ec2.rb
rm -f /var/lib/gems/2.3.0/gems/facter-2.5.7/lib/facter/ec2.rb

fi

if  [ $(lsb_release -rs) == "20.04" ]
then
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe'
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu xenial universe'
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu focal universe'
apt-get -y update
apt-get -y upgrade
cp -r Gemfile2004 Gemfile
sudo apt-get -y install build-essential ruby-full

gem install bundler --no-document

bundle
bundle update

# hack to remove the problematic ec2 fact, see: https://pihemr.atlassian.net/browse/UHM-3869
# not sure if this is an issue but for now removing them too
rm -f /var/lib/gems/2.7.0/gems/facter-2.5.7/lib/facter/util/ec2.rb
rm -f /var/lib/gems/2.7.0/gems/facter-2.5.7/lib/facter/ec2.rb

fi

echo "modulepath = /etc/puppet/modules:/etc/puppet/mirebalais-modules" > puppet.conf
echo "environment = $1" >> puppet.conf
