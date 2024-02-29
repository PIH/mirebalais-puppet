Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node 'default' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip

  include java
  include mysql_setup

  include tomcat

  include openmrs::apzu

}
