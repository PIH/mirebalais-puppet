class openmrs::owa (
  $tomcat = hiera('tomcat'),
  $owa_cohort_builder_version = hiera('owa_cohort_builder_version'),
  $package_release = hiera('package_release')
) {

  # add the owas that we use
  # TODO: add the ability to customize based on deployment, and/or use staging versions
  # TODO: this could become a pattern for installing modules as well?
  file { "/home/${tomcat}/.OpenMRS/owa":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # TODO: once we upgrade to Puppet 4.4+ we can just specific the file as as source (and therefore may not need exec wget and download every run)
  # TODO: come up with a more streamlined way to do this & handle versioning and whether we are installing a "stable" version or not, whether to switch Adds On and Bamboo, etc

  # install cohort builder from Add Ons
  /*exec{'retrieve_cohort_builder_owa':
    command => "/usr/bin/wget -q https://dl.bintray.com/openmrs/owa/cohortbuilder-${owa_cohort_builder_version}.zip -O /home/${tomcat}/.OpenMRS/owa/cohortbuilder.zip",
    require => File["/home/${tomcat}/.OpenMRS/owa"]
  }

  file { "/home/${tomcat}/.OpenMRS/owa/cohortbuilder.zip":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_cohort_builder_owa'],
    notify  => Exec['tomcat-restart']
  }*/

  # remove old order entry filename & directory
  # TODO can this now be removed
  file { "/home/${tomcat}/.OpenMRS/owa/openmrs-owa-orderentry.zip":
    ensure   => absent,
    notify  => Exec['tomcat-restart']
  }

  file { "/home/${tomcat}/.OpenMRS/owa/openmrs-owa-orderentry":
    ensure   => absent,
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Exec['tomcat-restart']
  }

  # install order entry from bamboo
  exec{'retrieve_order_entry_owa':
    command => "/usr/bin/wget -q http://bamboo.pih-emr.org/owa-repo/${package_release}orderentry.zip -O /home/${tomcat}/.OpenMRS/owa/orderentry.zip",
    require => File["/home/${tomcat}/.OpenMRS/owa"]
  }

  file { "/home/${tomcat}/.OpenMRS/owa/orderentry.zip":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_order_entry_owa'],
    notify  => [ Exec['tomcat-restart'], Exec['apache-restart'] ]
  }

  # remove old lab workflow filename and directory
  # TODO can this now be removed
  file { "/home/${tomcat}/.OpenMRS/owa/openmrs-owa-labworkflow.zip":
    ensure   => absent,
    notify  => Exec['tomcat-restart']
  }

  file { "/home/${tomcat}/.OpenMRS/owa/openmrs-owa-labworkflow":
    ensure  => absent,
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Exec['tomcat-restart']
  }

  # install lab workflow from bamboo
  exec{'retrieve_lab_workflow_owa':
    command => "/usr/bin/wget -q http://bamboo.pih-emr.org/owa-repo/${package_release}labworkflow.zip -O /home/${tomcat}/.OpenMRS/owa/labworkflow.zip",
    require => File["/home/${tomcat}/.OpenMRS/owa"]
  }

  file { "/home/${tomcat}/.OpenMRS/owa/labworkflow.zip":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_lab_workflow_owa'],
    notify  => [ Exec['tomcat-restart'], Exec['apache-restart'] ]
  }

  # install oncology owa from bamboo
 /* exec{'retrieve_oncology_owa':
    command => "/usr/bin/wget -q http://bamboo.pih-emr.org/owa-repo/${package_release}openmrs-owa-oncology.zip -O /home/${tomcat}/.OpenMRS/owa/openmrs-owa-oncology.zip",
    require => File["/home/${tomcat}/.OpenMRS/owa"]
  }

  file { "/home/${tomcat}/.OpenMRS/owa/openmrs-owa-oncology.zip":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_oncology_owa'],
    notify  => Exec['tomcat-restart']
  }*/



}
