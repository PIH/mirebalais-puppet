Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }


/* we comment out the "default" node so that we don't inadvertently install on a machine that doesn't have it's
fully-qualifed-domain-name properly configured; when testing on a VM, you can uncomment this to test the install */

/*node default {

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
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

}*/

node 'emr.hum.ht' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat
  include docker

  include openmrs
  include openmrs::initial_setup

  include mirth
#  include mirth::channel_setup

  #include monitoring
  include logging

  include openmrs::backup
}

node 'hai-hum-inf-humtest' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include percona

}

node 'hai-cloud-inf-omrshiv' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat
  include docker

  include openmrs
  include openmrs::initial_setup

  include openmrs::backup

}

node 'hai-cloud-inf-omrshiv-report' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup

  include docker

  include percona::install_restore_scripts
  include percona::setup_cron_to_refresh_report_dbs

  include petl
  include petl::mysql
}

node 'zt-cloud-ces-dw-prod' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup
  include docker

  include percona::install_restore_scripts
  include percona::setup_cron_to_refresh_report_dbs

  include petl::java
  include petl
}

node 'humci.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include tomcat
  include apache2

  include openmrs
  include openmrs::initial_setup
  include openmrs::backup

  include docker
  include percona

  include openmrs::atomfeed

  include petl

}

node 'vagrant-test.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include docker
  include commcare_sync

}

node 'emrtest.hum.ht', 'humdemo.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  include logging
}

node 'hai-hum-inf-omrs-report' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs

  include docker
  include percona::install_restore_scripts
  class { 'percona::setup_cron_to_refresh_openmrs_db':
    site_name => 'haiti/mirebalais',
    percona_restore_deidentify => false
  }
}

node 'inf-dakakind-omrs-test' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include tomcat

  include openmrs
  include openmrs::initial_setup

}

node 'pleebo.pih-emr.org', 'jjdossen.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat
  include docker

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  #include logging

  include openmrs::backup
}

node 'thomonde.pih-emr.org', 'hinche.pih-emr.org', 'cercalasource.pih-emr.org', 'lacolline.pih-emr.org', 'belladere.pih-emr.org', 'hsn.pih-emr.org', 'boucancarre.pih-emr.org', 'cange.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat
  include docker

  include openmrs
  include openmrs::initial_setup
  include openmrs::backup

}

node 'zltraining-fingerprints.pih-emr.org','zltraining.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup
}
node 'wellbody.pih-emr.org', 'kgh.pih-emr.org', 'zt-sl-kgh-inf-omrs-prod' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  include logging

  include openmrs::backup
}

node 'kouka.pih-emr.org', 'gladi.pih-emr.org', 'inf-ami-omrs-ci', 'kgh-test.pih-emr.org', 'sl-kgh-omrs-test.pih-emr.org', 'hinche-ci.pih-emr.org', 'zt-cloud-sis-inf-omrs-mfa-test', 'ocltest.pih-emr.org', 'sl-wellbody-inf-omrs-cc-test',
'belladere-test.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup
  include docker

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

}


node 'ci.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

}

node 'ces-ci.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup
  include docker

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include petl
}


node 'peru-ci.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

}

node 'ses-cor.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include tomcat
  include apache2

  include openmrs
  include openmrs::initial_setup
  include openmrs::backup

}

node 'haitihivtest.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include docker
  include percona::install_restore_scripts
  class { 'percona::setup_cron_to_refresh_openmrs_db':
    site_name => 'haiti/haitihiv'
  }

}

node 'ces.pih-emr.org', 'ces-capitan.pih-emr.org'{

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include tomcat
  include apache2
  include docker

  include openmrs
  #include openmrs::initial_setup
  include openmrs::backup
}

# note that we have two "ces-laguna" because for some reason the laguna fqdn is "ces-laguna.lan" (from some googling, .lan a suffx to a FQDN that may be added by routers)
# we don't need to create a "ces-laguna.lan.yml", because the hiera falls back to the regular hostbame if it can't find a match for the fqdn, see hiera.yaml
node 'ces-capitan', 'ces-honduras', 'ces-laguna', 'ces-laguna.lan', 'ces-letrero', 'ces-matazano', 'ces-monterrey',
    'ces-plan-baja', 'ces-plan-alta', 'ces-reforma', 'ces-salvador', 'ces-salvador.lan', 'ces-soledad' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include tomcat
  include docker

  include openmrs
  #include openmrs::initial_setup
  include openmrs::backup

  include cesemr_user_resources

  #include monitoring
}

node 'pleebo-mirror.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include monitoring
  include logging
}

node 'zt-cloud-dw-petl-test' {

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
  include maven_setup
  include docker

  include percona::install_restore_scripts

  class { 'percona::setup_cron_to_refresh_report_dbs':
    reporting_system => 'petl-test'
  }

  petl::install { 'install-petl-zl-etl':
    petl => "petl",
    petl_user => "petl",
    petl_home_dir => "/opt/petl",
    petl_site => "zl-test",
    petl_config_name => "zl-etl",
    petl_config_version => "1.13.0-SNAPSHOT",
    petl_server_port => 9109,
    petl_sqlserver_databaseName => "openmrs_haiti_warehouse",
    petl_cron_time => "0 0 22 ? * *",
  }

  petl::install { 'install-petl-ces-etl':
    petl => "petl-ces",
    petl_user => "petl-ces",
    petl_home_dir => "/opt/petl-ces",
    petl_site => "ces-test",
    petl_config_name => "ces-etl",
    petl_config_version => "1.14.0-SNAPSHOT",
    petl_server_port => 9110,
    petl_sqlserver_databaseName => "openmrs_ces_warehouse",
    petl_cron_time => "0 0 4 ? * *",
  }

}

node 'malawi-dw.pih-emr.org' {

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

  include petl
  include petl::disable_petl_startup_on_boot

}

node 'neno.pih-emr.org', 'lisungwi.pih-emr.org', 'mal-u-neno-inf-omrs-01'  {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  #include openmrs::backup

  include petl
  include petl::mysql

}

node 'neno-ci.pih-emr.org'  {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include maven_setup

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
}

node 'ccsync.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mail
  include ntpdate
  include maintenance
  include wget
  include unzip
  include docker
  include commcare_sync

}
