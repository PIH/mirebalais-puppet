#!/bin/bash

### These below packages are required for installing mysql 5.6
#######################################################################
osPackagesToDowload=(
http://archive.ubuntu.com/ubuntu/pool/main/s/sysvinit/initscripts_2.88dsf-59.3ubuntu2_amd64.deb
http://archive.ubuntu.com/ubuntu/pool/main/s/sysvinit/sysv-rc_2.88dsf-59.3ubuntu2_all.deb
http://archive.ubuntu.com/ubuntu/pool/main/i/insserv/insserv_1.14.0-5ubuntu3_amd64.deb
)

downloadedOsPackages=(
sysv-rc_2.88dsf-59.3ubuntu2_all.deb
insserv_1.14.0-5ubuntu3_amd64.deb
initscripts_2.88dsf-59.3ubuntu2_amd64.deb
)

downloadOsPackages() {
                                        for osPackage in ${osPackagesToDowload[@]}
                                        do
                                                wget $osPackage
                                        done
}

installOsPackages() {
                                        for osPackages in ${downloadedOsPackages[@]}
                                        do
                                                /usr/bin/dpkg -i $osPackages
                                        done
}

removeOsPackages() {
                                        for osPackages in ${downloadedOsPackages[@]}
                                        do
                                                /bin/rm -rf $osPackages
                                        done
}

isPackageInstalled() {
    					/usr/bin/apt list --installed | grep "$1" &> /dev/null
}

# hack to make sure we have ruby1.9 installed instead of ruby1.8
### ubuntu 15.04
if [ $(lsb_release -rs) == "14.04" ]
then
cp -r Gemfile1404 Gemfile
apt-get remove ruby1.8
apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 \
build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

gem install bundler --no-ri --no-rdoc

bundle

fi

### ubuntu 16.04
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

### ubuntu 20.04
if  [ $(lsb_release -rs) == "20.04" ]
then
### authenticating old repos since its some required packages
## are available in old repos
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe'
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu xenial universe'
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu focal universe'
add-apt-repository 'deb http://security.ubuntu.com/ubuntu bionic-security main'

apt-get -y update
apt-get -y upgrade
cp -r Gemfile2004 Gemfile

apt-get -y install build-essential

## puppet 5 doesnot work with ruby 2.7, ensuring that ruby 2.7 is not installed.
## note: ruby 2.7 is the official ruby version of ubuntu 20.04
apt-mark hold libruby2.7:i386 ruby:i386 ruby2.7:i386 libruby2.7 ruby2.7 libruby2.7:amd64.deb ruby2.7:amd64.deb
apt-get autoclean -y

### If ruby2.5 is already installed, do no remove it
if ! isPackageInstalled ruby2.5 ; then
  echo "installing ruby2.5"
	apt-get purge -y ruby*

	## remove these files because they cause conflicts
	/bin/rm -rf /var/lib/gems/2.7.0
	/bin/rm -rf /var/lib/gems/2.3.0
	/bin/rm -rf /var/lib/gems/1.9.0
	/bin/rm -rf /var/lib/gems/1.9.1
	/bin/rm -rf /usr/local/bin/librarian-puppet
  /bin/rm -rf /usr/local/bin/puppet

	/usr/bin/apt-get -y install libssl-dev

	# ruby 2.5
  apt-add-repository -y ppa:brightbox/ruby-ng
  apt-get -y update
  apt-get -y upgrade
	apt-get -y dist-upgrade
	
	/usr/bin/apt install -y rake ruby-did-you-mean libruby2.5 ruby2.5

	bundle update --bundler

else
	echo "ruby2.5 is already installed"
fi

### if mysql-server-5.6 does not exist, install it. If it exists, do not remove
if ! isPackageInstalled mysql-server-5.6 ; then
  echo "removing none required packges and installing required packages for mysql-server-5.6 to be installed"
	#### remove any default version of mysql installed if mysql 5.6 has not been installed
	### puppet takes care of installing mysql 5.6 later
	apt-get purge -y php-mysql php7.4-mysql  libdbd-mysql* libdbd-mysql-perl libmysqlclient21 mysql*
	/bin/rm -rf /var/lib/mysql
	/bin/rm -rf /var/lib/mysql-keyring
	/bin/rm -rf /var/lib/mysql-files
	/bin/rm -rf /etc/mysql
	apt-get autoclean -y

	removeOsPackages
	downloadOsPackages
	installOsPackages
	removeOsPackages

else
        echo "mysql-server-5.6 is already installed"
fi

apt-get autoremove -y

gem install bundler --no-ri --no-rdoc

bundle
bundle update

# hack to remove the problematic ec2 fact
/bin/rm -rf /var/lib/gems/2.5.0/gems/facter-2.5.7/lib/facter/ec2.rb
/bin/rm -rf /var/lib/gems/2.5.0/gems/facter-2.5.7/lib/facter/util/ec2.rb

fi

echo "modulepath = /etc/puppet/modules:/etc/puppet/mirebalais-modules" > puppet.conf
echo "environment = $1" >> puppet.conf