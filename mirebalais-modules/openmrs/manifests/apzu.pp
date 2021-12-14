class openmrs::apzu (

  $tomcat                               = hiera('tomcat'),
  $tomcat_home_dir                      = hiera('tomcat_home_dir'),
  $webapp_name                          = hiera('webapp_name'),
  $pih_malawi_distribution_version      = hiera('pih_malawi_distribution_version'),
  $openmrs_db                   = hiera('openmrs_db'),
  $openmrs_db_user              = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password          = decrypt(hiera('openmrs_db_password')),
  $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
  $repo_url                     = decrypt(hiera('repo_url')),

) {

  require openmrs

  include openmrs::pwa

  file { "${tomcat_home_dir}/.OpenMRS/${webapp_name}-runtime.properties":
    ensure  => present,
    content => template('openmrs/openmrs-malawi-runtime.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  file { "${tomcat_home_dir}/.OpenMRS/modules":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  exec { 'cleanup-malawi-openmrs-distribution-dir':
    command => "rm -rf /tmp/malawi-openmrs-distribution && rm -rf /tmp/malawi-distro && rm -rf /tmp/malawi-distribution"
  }

  wget::fetch { 'download-malawi-openmrs-distribution':
    source      => "${repo_url}:81/malawi-repo/pihmalawi-distribution-${pih_malawi_distribution_version}.zip",
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