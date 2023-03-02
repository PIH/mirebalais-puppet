class openmrs::install_maven_distro (

  $package_name     = hiera('package_name'),
  $package_version  = hiera('package_version'),
  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir')

) {

  file { "/usr/local/sbin/download-maven-artifact.sh":
    ensure  => present,
    source  => "puppet:///modules/openmrs/download-maven-artifact.sh",
    owner   => root,
    group   => root,
    mode    => '0700',
  }

  exec { 'cleanup-openmrs-maven-distribution-dir':
   command => "rm -rf /tmp/${package_name}-${package_version}.zip && rm -rf /tmp/${package_name}-${package_version}"
  }

  exec { 'download-distro-from-maven':
    command => "/usr/local/sbin/download-maven-artifact.sh --groupId=org.openmrs.distro --artifactId=${package_name} --version=${package_version} --classifier= --type=zip --targetDir=/tmp",
    timeout     => 10000,
    require => [Exec['cleanup-openmrs-maven-distribution-dir'], File["/usr/local/sbin/download-maven-artifact.sh"]]
  }

  exec { 'extract-distro':
    command => "unzip -o /tmp/${package_name}-${package_version}.zip -d /tmp",
    require => [ Exec['cleanup-openmrs-maven-distribution-dir'], Package['unzip']]
  }

  exec { 'move-distro-modules-to-openmrs-home-dir':
    command => "rm -rf ${tomcat_home_dir}/.OpenMRS/modules/* && cp -r /tmp/${package_name}-${package_version}/openmrs_modules/* ${tomcat_home_dir}/.OpenMRS/modules/ && chown -R ${tomcat}:${tomcat} ${tomcat_home_dir}/.OpenMRS/modules",
    require => [ Exec['extract-distro'], Exec['download-distro-from-maven']],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'move-distro-war-file':
    command => "rm -rf /var/lib/${tomcat}/webapps/* && cp -r /tmp/${package_name}-${package_version}/openmrs_webapps/openmrs.war /var/lib/${tomcat}/webapps && chown -R ${tomcat}:${tomcat} /var/lib/${tomcat}/webapps",
    require => [ Exec['download-distro-from-maven'], Exec['extract-distro'] ],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

}