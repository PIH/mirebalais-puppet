class openmrs::sync2 (
  $tomcat = hiera('tomcat'),
  $atomfeed_version = hiera('atomfeed_version'),
  $fhir_version = hiera('fhir_version'),
  $sync2_version = hiera('sync2_version'),
  $package_release = hiera('package_release')
) {

  # TODO: once we upgrade to Puppet 4.4+ we can just specific the file as as source
  #   (and therefore may not need exec wget and download every run)
  # TODO: come up with a more streamlined way to do this & handle versioning and whether
  #   we are installing a "stable" version or not, whether to switch Adds On and Bamboo, etc

  file { "/home/${tomcat}/.OpenMRS/modules":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # install atomfeed from mavenrepo.openmrs.org
  exec{'retrieve_atomfeed':
    command => "/usr/bin/wget -q https://mavenrepo.openmrs.org/omods/omod/atomfeed-${atomfeed_version}.omod -O /home/${tomcat}/.OpenMRS/modules/atomfeed-${atomfeed_version}.omod ",
    require => File["/home/${tomcat}/.OpenMRS/modules"]
  }

  file { "/home/${tomcat}/.OpenMRS/modules/atomfeed-${atomfeed_version}.omod":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_atomfeed'],
    notify  => Exec['tomcat-restart']
  }

  # install fhir from mavenrepo.openmrs.org
  exec{'retrieve_fhir':
    command => "/usr/bin/wget -q https://mavenrepo.openmrs.org/omods/omod/fhir-${fhir_version}.omod -O /home/${tomcat}/.OpenMRS/modules/fhir-${fhir_version}.omod ",
    require => File["/home/${tomcat}/.OpenMRS/modules"]
  }

  file { "/home/${tomcat}/.OpenMRS/modules/fhir-${fhir_version}.omod":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_fhir'],
    notify  => Exec['tomcat-restart']
  }

  # install sync 2 from mavenrepo.openmrs.org
  exec{'retrieve_sync2':
    command => "/usr/bin/wget -q https://mavenrepo.openmrs.org/omods/omod/sync2-${sync2_version}.omod -O /home/${tomcat}/.OpenMRS/modules/sync2-${sync2_version}.omod ",
    require => File["/home/${tomcat}/.OpenMRS/modules"]
  }

  file { "/home/${tomcat}/.OpenMRS/modules/sync2-${sync2_version}.omod":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_sync2'],
    notify  => Exec['tomcat-restart']
  }

}
