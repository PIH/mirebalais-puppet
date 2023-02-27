class openmrs::apzu (

  $pih_malawi_distribution_version      = hiera('pih_malawi_distribution_version')

) {

  require openmrs::openmrs_config_files
  require openmrs::pwa

  exec { 'cleanup-malawi-openmrs-distribution-dir':
    command => "rm -rf /tmp/malawi-openmrs-distribution && rm -rf /tmp/malawi-distro && rm -rf /tmp/malawi-distribution"
  }

  wget::fetch { 'download-malawi-openmrs-distribution':
    source      => "${repo_url}:81/malawi-repo/pihmalawi-${pih_malawi_distribution_version}.zip",
    destination => "/tmp/malawi-openmrs-distribution",
    timeout     => 0,
    verbose     => false,
    redownload  => true,
    require     => Exec['cleanup-malawi-openmrs-distribution-dir']
  }

  exec { 'extract-malawi-openmrs-distribution':
    command => "unzip -o /tmp/malawi-openmrs-distribution -d /tmp/malawi-distro",
    require => [ Wget::Fetch['download-malawi-openmrs-distribution'], Package['unzip']]
  }

  exec { 'move-malawi-openmrs-distribution':
    command => "mv /tmp/malawi-distro/* /tmp/malawi-distribution && rm -rf ${tomcat_home_dir}/.OpenMRS/modules/* && cp -r /tmp/malawi-distribution/openmrs_modules/* ${tomcat_home_dir}/.OpenMRS/modules/ && chown -R ${tomcat}:${tomcat} ${tomcat_home_dir}/.OpenMRS/modules",
    require => [ Wget::Fetch['download-malawi-openmrs-distribution'], Exec['extract-malawi-openmrs-distribution'], File["${tomcat_home_dir}/.OpenMRS/modules"]],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'move-malawi-war-file':
    command => "rm -rf /var/lib/${tomcat}/webapps/* && cp -r /tmp/malawi-distribution/openmrs_webapps/openmrs.war /var/lib/${tomcat}/webapps && chown -R ${tomcat}:${tomcat} /var/lib/${tomcat}/webapps",
    require => [ Wget::Fetch['download-malawi-openmrs-distribution'], Exec['extract-malawi-openmrs-distribution'] ],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

}