# mirebalais-puppet

Puppet project for PIH EMR. Can install PIH EMR and its dependencies on configured machines.

### More info
- https://github.com/PIH/openmrs-module-mirebalais
- http://mirebalaisemr.blogspot.com.br/

### How OpenMRS is configured in Puppet

Puppet matches the hostname of the target machine with a filename in
`hieradata`.

The chosen file has a parameter `pih_config`. This is a comma-separated
list of PIH config files to load. These config files are found in
`mirebalais-modules/openmrs/files/config/`.

It also has a parameter `config_dir`. This is the name of a directory in
`mirebalais-modules/openmrs/files/app-data-config/`. The selected
directory should contain only a directory named "configuration", which will
be copied to the root of the application data directory.

### Using Vagrant

```
vagrant up
vagrant ssh
sudo apt-get install openssh-server git
sudo rm -fR /etc/puppet
sudo mkdir /etc/puppet
sudo cp -a /vagrant/* /etc/puppet/
cd /etc/puppet
sudo ./install.sh local
```

### Using bundler

http://bundler.io/v1.7/rationale.html#checking-your-code-into-version-control

### How to enable Java debugging

On the server you wish to enable debugging on, edit `/etc/default/tomcat7.`. There is a line that reads `# To enable remote debugging uncomment the following line.` Uncomment the following line.
Note that one each redeploy this will be reset.


### Encryption/Decryption

We use puppet-decrypt to encrypt and decrypt passwords in our puppet scripts.

https://github.com/maxlinc/puppet-decrypt


### SSL & LetsEncrypt

LetsEncrypt uses the `site_domain` parameter in hieradata to generate an SSL cert.
Puppet only ever attempts to initialize it once, so if setup fails for any
reason you will need to `rm -r /var/acme` before running `./puppet-apply.sh site` again.


### Azcopy

Ensure that in the yaml file `az_backup_folder_path` is set correctly

for example for HUM:

```
az_backup_folder_path: haiti/mirebalais
```

where `haiti` is the country name and `mirebalais` is the site name.
