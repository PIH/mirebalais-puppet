#!/bin/bash

CES_PETL_CONFIG_VERSION=`cat /etc/puppet/hieradata/ces-ci.pih-emr.org.yaml | grep config_version`

cd /etc/puppet

# replace petl_config_name and petl_sqlserver_databaseName
sed -i 's/petl_config_name: openmrs-config-zl/petl_config_name: openmrs-config-ces/g' /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
sed -i 's/petl_sqlserver_databaseName: openmrs_haiti_warehouse/petl_sqlserver_databaseName: openmrs_ces_warehouse/g' /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
sed -i 's/zl-test/ces-test/g' /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
sed -i 's/petl: petl/petl: petl-ces/g' /etc/puppet/hieradata/petl-test.pih-emr.org.yaml

# delete petl_config_version
sed -i '/^petl_config_version\b/Id' /etc/puppet/hieradata/petl-test.pih-emr.org.yaml

# add petl_config_version after delete
echo $'' >> /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
echo "petl_${CES_PETL_CONFIG_VERSION}" >> /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
echo $'' >> /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
echo "petl_server_port: 9110" >> /etc/puppet/hieradata/petl-test.pih-emr.org.yaml
echo "petl_java_home: "/usr/lib/jvm/java8-ces-petl-test/jdk1.8.0_171" >> /etc/puppet/hieradata/petl-test.pih-emr.org.yaml

## Download java and extract java
rm -rf /usr/lib/jvm/java8-ces-petl-test
mkdir /usr/lib/jvm/java8-ces-petl-test
wget http://bamboo.pih-emr.org/java/jdk-8u171-linux-x64.tar.gz -P /usr/lib/jvm/java8-ces-petl-test
cd /usr/lib/jvm/java8-ces-petl-test
tar -xvf jdk-8u171-linux-x64.tar.gz