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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
  include openmrs::initial_setup

}*/

node 'emr.hum.ht' {

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

  include openmrs::pihemr
  include openmrs::initial_setup

  #include percona

  include mirth
  include mirth::channel_setup

  #include monitoring
  include logging

  include openmrs::backup
  include mirebalais_reporting::production_setup

}

node 'hai-hum-inf-humtest' {

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

  include openmrs::pihemr
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup

  include percona
  include petl
  include petl::mysql

}

node 'humci.pih-emr.org', 'vagrant-test.pih-emr.org' {

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
  include tomcat
  include apache2

  include openmrs::pihemr
  include openmrs::initial_setup

  include percona

  include openmrs::atomfeed

  include petl

}


node 'emrtest.hum.ht', 'humdemo.pih-emr.org' {

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

  include openmrs::pihemr
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
  #include openmrs::initial_setup

  include percona

  #include monitoring
  include logging

  include petl

  include mirebalais_reporting::reporting_setup
}

node 'pleebo.pih-emr.org', 'jjdossen.pih-emr.org' {

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

  include openmrs::pihemr
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
  include openmrs::initial_setup
  include openmrs::backup

}

node 'zltraining.pih-emr.org' {

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

  include openmrs::pihemr
  include openmrs::initial_setup
}

node 'wellbody.pih-emr.org', 'kgh.pih-emr.org' {

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

  include openmrs::pihemr
  include openmrs::initial_setup

  #include monitoring
  include logging

  include openmrs::backup
}

node 'kouka.pih-emr.org', 'gladi.pih-emr.org', 'ci.pih-emr.org', 'ami.pih-emr.org', 'kgh-test.pih-emr.org', 'hinche-ci.pih-emr.org', 'hsn-ci.pih-emr.org', 'ocltest.pih-emr.org' {

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

  include openmrs::pihemr
  include openmrs::initial_setup

}

node 'ces-ci.pih-emr.org' {

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

  include openmrs::pihemr
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
  include openmrs::initial_setup

}

node 'ses-cor.pih-emr.org' {

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
  include tomcat
  include apache2

  include openmrs::pihemr
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
  include openmrs::initial_setup

}

node 'haiti-test.pih-emr.org' {

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

  include openmrs::pihemr
  include openmrs::initial_setup

}

node 'haititest.pih-emr.org' {

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

  include openmrs::pihemr
  include openmrs::initial_setup

}

node 'ces.pih-emr.org', 'ces-capitan.pih-emr.org'{

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
  include tomcat
  include apache2

  include openmrs::pihemr
  include openmrs::initial_setup
  include openmrs::backup
}

node 'ces-capitan', 'ces-honduras', 'ces-laguna', 'ces-letrero', 'ces-matazano', 'ces-monterrey',
    'ces-plan-baja', 'ces-plan-alta', 'ces-reforma', 'ces-salvador', 'ces-soledad' {

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
  include tomcat

  include openmrs::pihemr
  include openmrs::initial_setup
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
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs::pihemr
  include openmrs::initial_setup

  include monitoring
  include logging
}

node 'petl-test.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }
## the commented lines are one time installation (uncomment if changes are made)
  include security
  include mail
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  #include mysql_setup

  #include percona
  include petl
  #include petl::mysql

}

node 'malawi-dw.pih-emr.org' {

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

  include petl
  include petl::disable_petl_startup_on_boot

}

node 'neno.pih-emr.org', 'lisungwi.pih-emr.org', 'neno20.pih-emr.org'  {

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
  include openmrs::backup

  include petl
  include petl::mysql

}
