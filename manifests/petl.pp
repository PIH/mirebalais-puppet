Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node default {

  class { 'apt':
    always_apt_update => true,
  }

  include wget
  include unzip
  include mysql_setup
  include petl::mysql
  include petl::java
  include petl

}

node 'malawi-dw.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include wget
  include unzip
  include mysql_setup
  include petl::mysql
  include petl::java
  include petl::uninstall_service

}