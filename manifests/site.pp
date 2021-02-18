Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }


/* we comment out the "default" node so that we don't inadvertently install on a machine that doesn't have it's
fully-qualifed-domain-name properly configured; when testing on a VM, you can uncomment this to test the install */

/*node default {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
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
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include percona

  include mirth
  include mirth::channel_setup

  #include monitoring
  include logging

  include openmrs::backup
  include crashplan
  include mirebalais_reporting::production_setup

}

node 'humci.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include tomcat
  include apache2

  include openmrs
  include openmrs::initial_setup

  include percona

  include openmrs::atomfeed

  include petl

  #include mirth
  #include mirth::channel_setup

  #include monitoring
}


node 'emrtest.hum.ht', 'humdemo.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  include logging
}

node 'reporting.hum.ht' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

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
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  #include logging

  include openmrs::backup
  include crashplan
}

node 'thomonde.pih-emr.org', 'hinche-server.pih-emr.org', 'cercalasource.pih-emr.org', 'lacolline.pih-emr.org', 'belladere.pih-emr.org', 'zltraining.pih-emr.org', 'hsn.pih-emr.org', 'boucancarre.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  #include logging

  include openmrs::backup

  # Crashplan removed (May 2018)
}

node 'zltraining.pih-emr.org.orig' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup
}

node 'wellbody.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
  include logging

  include openmrs::backup
  include crashplan
}

node 'kouka.pih-emr.org', 'gladi.pih-emr.org', 'ci.pih-emr.org', 'ami.pih-emr.org', 'ces-ci.pih-emr.org', 'peru-ci.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  #include monitoring
}

node 'haitihivtest.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include percona

  include petl

  #include monitoring
}

node 'haiti-test.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include percona

}

node 'haititest.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include percona
}

node 'ces.pih-emr.org', 'ces-capitan.pih-emr.org', 'ces-laguna.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include tomcat
  include apache2

  include openmrs
  include openmrs::initial_setup
  include openmrs::backup
}

node 'ces-capitan', 'ces-honduras', 'ces-laguna', 'ces-letrero', 'ces-matazano', 'ces-monterrey',
    'ces-plan', 'ces-reforma', 'ces-salvador', 'ces-soledad' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include cesemr_user_resources

  #include monitoring
}

node 'pleebo-mirror.pih-emr.org' {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include unzip

  include java
  include mysql_setup
  include apache2
  include tomcat

  include openmrs
  include openmrs::initial_setup

  include monitoring
  include logging
}
