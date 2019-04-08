# mirebalais-puppet

Puppet project for PIH EMR. Can install PIH EMR and its dependencies on configured machines.

### More info
- https://github.com/PIH/openmrs-module-mirebalais
- http://mirebalaisemr.blogspot.com.br/

### Using Vagrant

* vagrant up
* vagrant ssh
* sudo apt-get install openssh-server git
* sudo rm -fR /etc/puppet
* sudo mkdir /etc/puppet
* sudo cp -a /vagrant/* /etc/puppet/
* cd /etc/puppet
* sudo ./install.sh local

### Using bundler

http://bundler.io/v1.7/rationale.html#checking-your-code-into-version-control

### How to enable Java debugging

Edit `/mirebalais-modules/tomcat/templates/default.erb`. There is a line that reads `# To enable remote debugging uncomment the following line.` Uncomment the following line.
