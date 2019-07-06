#! /bin/bash

if [ ! -d /etc/puppet-decrypt ]
then
    mkdir /etc/puppet-decrypt
fi

if [ "$1" != "local" ]
then
  if [ ! -f /etc/puppet-decrypt/encryptor_secret_key ] || [ ! -f /etc/ssl/private/hum.key ] || [ ! -f /etc/ssl/private/pih-emr.org.key ]
  then
    echo "Please provide a username to fetch private data"
    read user

    scp $user@amigo.pih-emr.org:/etc/mirebalais/* .

    mv encryptor_secret_key /etc/puppet-decrypt/
    mv hum.key /etc/ssl/private/
    mv pih-emr.org.key /etc/ssl/private/
  fi

  if [ ! -d ~/.ssh ]
  then
    mkdir ~/.ssh
  fi

  if [ ! -f ~/.ssh/id_dsa ]
  then
    ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -P ''
  fi

  echo "Please make sure you have copied this ssh public key to the backup server so that database backups can be uploaded there:"
  cat ~/.ssh/id_dsa.pub
  read -p "Press a key to continue"

else
    if [ !  -f /etc/puppet-decrypt/encryptor_secret_key ]
    then
	echo "Creating a dummy secret key"
	ssh-keygen -N testmeout -f /etc/puppet-decrypt/encryptor_secret_key
    fi
fi 

# For Haiti servers, don't update the tzdata package
if [ "$HOSTNAME" = "" ]
then
    apt-mark hold tzdata
fi

apt-get update

./gem-update.sh
./puppet-apply.sh site


