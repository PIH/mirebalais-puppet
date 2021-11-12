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
As root, create a Vagrant directory
cd into this directory and create a VagrantFile with the contents of the VagrantFile in this repo (see above)
vagrant up
vagrant ssh
sudo apt-get install openssh-server git
sudo rm -rf /etc/puppet
git clone https://github.com/PIH/mirebalais-puppet.git /etc/puppet
cd /etc/puppet
sudo ./install.sh (note that you have to have credentials to log into the amigo server)
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

### Upgrading to Ubuntu 20.04
To upgrade the existing servers to Ubuntu 20.04 ensure that you hold the necessary packages required for the PIHEMR to run.
There is a script called hold-packages.sh that you can run to hold these packages. Ensure that you run this script before upgrading to any new ubuntu distribution

To upgrade to ubuntu 18.04
```
./hold-packages.sh
do-release-upgrade
```

To upgrade to ubuntu 20.04
```
./hold-packages.sh
do-release-upgrade
```
### Petl
petl supports the sites below
```aidl
Production
  apzu
  ces
  imb
  zl-hiv
  zl-report  

Test
  zl-test (for petl-test.pih-emr.org)
  humci
```
The pih-pentaho repo still hosts the rwanda etl. If you are installing a rwanda etl server, ensure that in the yaml file you set
```
imb_etl: true
```
#### *application.yml*

The application.yml file holds all the etl configs, the respective configuration are represented as below. site_name can be any of the site mentioned above.
```
<% if @petl_site == "site_name" -%>

     site config details
     
<% end -%>
```

#### *Installing multiple petl instances on the same server.*

This is achievable by running puppet more than once (on the same server). 
***Note that this is not recommened on a productions instance*** 

To install more that one petl instance on the same server, change the below variables 
```aidl
  petl: 
  petl_site:
  petl_config_name:
  petl_config_version:
```
