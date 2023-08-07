Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

/* we comment out the "default" node so that we don't inadvertently install on a machine that doesn't have it's
fully-qualifed-domain-name properly configured; when testing on a VM, you can uncomment this to test the install */

/*
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
*/

 node 'zt-imb-his-omrs-dw'{

   class { 'apt':
     always_apt_update => true,
   }

   include wget
   include unzip
   include docker
   include docker::install_container
   include petl::java
   include petl

 }

node 'malawi-dw.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include wget
  include unzip
  include petl::java
  include petl
  include petl::disable_petl_startup_on_boot

}

node 'zt-sl-kgh-inf-dw-prod' {

  class { 'apt':
    always_apt_update => true,
  }

  include wget
  include unzip
  include petl::java
  include petl

}