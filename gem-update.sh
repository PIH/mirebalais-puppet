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

if [ $(lsb_release -rs) == "16.04" ]
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
add-apt-repository 'deb http://security.ubuntu.com/ubuntu bionic-security main'
apt-get -y update
apt-get -y upgrade
#apt -y update && apt-cache policy libssl-dev
#apt -y install rvenv
apt-get -y install libssl-dev
#rbenv install 2.3.3
cp -r Gemfile2004 Gemfile

rm -rf ruby_2.5.1_amd64*
rm -rf libffi6_3.2.1-8_amd64*
rm -rf libgdbm5_1.14.1-6_amd64*
rm -rf libreadline7_7.0-3_amd64*
rm -rf libtinfo5_6.1-1ubuntu1_amd64*

apt-get purge -y ruby
apt-get autoclean -y

apt-get -y install build-essential
apt-get -f install
apt --fix-broken install

wget http://archive.ubuntu.com/ubuntu/pool/main/g/gdbm/libgdbm5_1.14.1-6_amd64.deb
dpkg -i libgdbm5_1.14.1-6_amd64.deb 
wget http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
dpkg -i libffi6_3.2.1-8_amd64.deb
dpkg -i http://archive.ubuntu.com/ubuntu/pool/main/r/readline/libreadline7_7.0-3_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/r/readline/libreadline7_7.0-3_amd64.deb
dpkg -i libreadline7_7.0-3_amd64.deb 
wget http://archive.ubuntu.com/ubuntu/pool/main/n/ncurses/libtinfo5_6.1-1ubuntu1_amd64.deb
dpkg -i libtinfo5_6.1-1ubuntu1_amd64.deb 
dpkg -i libreadline7_7.0-3_amd64.deb 

apt-mark hold libruby2.7:i386 ruby:i386 ruby2.7:i386 libruby2.7 ruby2.7
apt install rake libruby2.5 ruby2.5

wget http://launchpadlibrarian.net/362101842/ruby_2.5.1_amd64.deb
dpkg -i ruby_2.5.1_amd64.deb 
 
wget http://archive.ubuntu.com/ubuntu/pool/main/s/sysvinit/initscripts_2.88dsf-59.3ubuntu2_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/s/sysvinit/sysv-rc_2.88dsf-59.3ubuntu2_all.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/i/insserv/insserv_1.14.0-5ubuntu3_amd64.deb

dpkg -i insserv_1.14.0-5ubuntu3_amd64.deb
dpkg -i sysv-rc_2.88dsf-59.3ubuntu2_all.deb
dpkg -i initscripts_2.88dsf-59.3ubuntu2_amd64.deb


rm -rf ruby_2.5.1_amd64*
rm -rf libffi6_3.2.1-8_amd64*
rm -rf libgdbm5_1.14.1-6_amd64*
rm -rf libreadline7_7.0-3_amd64*
rm -rf libtinfo5_6.1-1ubuntu1_amd64*

gem install bundler --no-document

bundle
bundle update

# hack to remove the problematic ec2 fact, see: https://pihemr.atlassian.net/browse/UHM-3869
# not sure if this is an issue but for now removing them too
#rm -f /var/lib/gems/2.7.0/gems/facter-2.5.7/lib/facter/util/ec2.rb
#rm -f /var/lib/gems/2.7.0/gems/facter-2.5.7/lib/facter/ec2.rb
#puppet module install pegas-cron --version 0.10.0

fi

echo "modulepath = /etc/puppet/modules:/etc/puppet/mirebalais-modules" > puppet.conf
echo "environment = $1" >> puppet.conf
