Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node 'neno.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::apzu
}
