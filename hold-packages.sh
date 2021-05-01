#!/bin/bash

set +x

packages=(
## mysql
libdbd-mysql-perl
libmysqlclient20
mysql-client-5.6
mysql-client-core-5.6
mysql-common
mysql-server-5.6
mysql-server-core-5.6
## apache2
apache2
apache2-bin
apache2-data
apache2-utils
libapache2-mod-jk
## tomcat7
libtomcat7-java
tomcat7
tomcat7-common
## java
ca-certificates-java
java-common
javascript-common
libcommons-collections3-java
libcommons-dbcp-java
libcommons-pool-java
libecj-java
libservlet3.0-java
libtomcat7-java
)

holdPackagesForUpgrade()
                              {
                               for item in ${packages[@]}
                                        do
                                                /usr/bin/apt-mark hold $item
                                        done
                              }
holdPackagesForUpgrade