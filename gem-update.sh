#!/bin/bash

deleteDownloadedRubyPackages=(
ruby_2.5.1_amd64*
libffi6_3.2.1-8_amd64*
libgdbm5_1.14.1-6_amd64*
libreadline7_7.0-3_amd64*
libtinfo5_6.1-1ubuntu1_amd64*
initscripts_2.88dsf-59.3ubuntu2_amd64*
sysv-rc_2.88dsf-59.3ubuntu2_all*
insserv_1.14.0-5ubuntu3_amd64*
)

osPackagesToDowload=(
http://archive.ubuntu.com/ubuntu/pool/main/s/sysvinit/initscripts_2.88dsf-59.3ubuntu2_amd64.deb
http://archive.ubuntu.com/ubuntu/pool/main/s/sysvinit/sysv-rc_2.88dsf-59.3ubuntu2_all.deb
http://archive.ubuntu.com/ubuntu/pool/main/i/insserv/insserv_1.14.0-5ubuntu3_amd64.deb
)

downloadedOsPackages=(
initscripts_2.88dsf-59.3ubuntu2_amd64.deb
sysv-rc_2.88dsf-59.3ubuntu2_all.deb
insserv_1.14.0-5ubuntu3_amd64.deb
)

downloadUrlRuby=(
http://archive.ubuntu.com/ubuntu/pool/main/g/gdbm/libgdbm5_1.14.1-6_amd64.deb
http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
http://archive.ubuntu.com/ubuntu/pool/main/r/readline/libreadline7_7.0-3_amd64.deb
http://archive.ubuntu.com/ubuntu/pool/main/n/ncurses/libtinfo5_6.1-1ubuntu1_amd64.deb
http://launchpadlibrarian.net/362101842/ruby_2.5.1_amd64.deb
)

rubyPackages=(
libtinfo5_6.1-1ubuntu1_amd64.deb
libgdbm5_1.14.1-6_amd64.deb
libffi6_3.2.1-8_amd64.deb
libreadline7_7.0-3_amd64.deb
)

deleteDownloadedRubyPackages() {
                                        for rubyPackage in ${deleteDownloadedRubyPackages[@]}
                                        do
                                                /bin/rm -rf $rubyPackage
                                        done
}


downloadOsPackages() {
                                        for osPackage in ${osPackagesToDowload[@]}
                                        do
                                                wget $osPackage
                                        done
}

downloadRubyPackages() {
                                        for rubyPackage in ${downloadUrlRuby[@]}
                                        do
                                                wget $rubyPackage
                                        done

}

installRuby() {
                                        for rubyPackage in ${rubyPackages[@]}
                                        do
                                                /usr/bin/dpkg -i $rubyPackage
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
cp -r Gemfile2004 Gemfile

apt-get -y install build-essential

### If ruby2.5 is already installed, do no remove it
if ! isPackageInstalled ruby2.5 ; then

	apt-get purge -y ruby
	apt-get autoclean -y

	apt-mark hold libruby2.7:i386 ruby:i386 ruby2.7:i386 libruby2.7 ruby2.7

	apt-get -f install
	apt --fix-broken install

        echo "installing ruby2.5"
	/usr/bin/apt-get -y install libssl-dev
	deleteDownloadedRubyPackages
	downloadRubyPackages
	installRuby
	deleteDownloadedRubyPackages

	/usr/bin/apt install -y rake libruby2.5 ruby2.5
	/usr/bin/dpkg -i ruby_2.5.1_amd64.deb
else
	echo "ruby2.5 is already installed"
fi

### if mysql-server-5.6 does not exist, install it. If it exists, do not remove
if ! isPackageInstalled mysql-server-5.6 ; then
        echo "installing required packages for mysql-server-5.6 to be installed"
	/bin/rm -rf /var/lib/mysql/debian-*
	removeOsPackages
	downloadOsPackages
	installOsPackages
	removeOsPackages
else
        echo "mysql-server-5.6 is already installed"
fi

gem install bundler --no-document

bundle
bundle update

apt-get -f install
apt --fix-broken install
apt-get update --allow-insecure-repositories

fi

echo "modulepath = /etc/puppet/modules:/etc/puppet/mirebalais-modules" > puppet.conf
echo "environment = $1" >> puppet.conf
