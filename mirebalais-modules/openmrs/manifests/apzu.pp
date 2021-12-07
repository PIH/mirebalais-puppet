class openmrs::apzu (
  $tomcat_home_dir              = hiera('tomcat_home_dir'),
  $tomcat                       = hiera('tomcat'),
  $webapp_name                  = hiera('webapp_name'),
  $openmrs_db                   = hiera('openmrs_db'),
  $openmrs_db_user              = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password          = decrypt(hiera('openmrs_db_password')),
  $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
  $repo_url                     = decrypt(hiera('repo_url')),

) {

  include openmrs::pwa

  file { "${tomcat_home_dir}/.OpenMRS":
    ensure => directory,
    owner  => $tomcat,
    group  => $tomcat,
    require => File["${tomcat_home_dir}"]
  }

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

  exec { 'cleanup-malawi-modules-dir':
    command => "rm -rf /tmp/malawi-modules && rm -rf /tmp/malawi-distro"
  }

  wget::fetch { 'download-malawi-modules':
    source      => "${repo_url}:81/malawi-repo/modules.zip",
    destination => "/tmp/malawi-modules",
    timeout     => 0,
    verbose     => false,
    redownload  => true,
    require     => Exec['cleanup-malawi-modules-dir']
  }

  exec { 'extract-malawi-modules':
    command => "unzip -o /tmp/malawi-modules -d /tmp/malawi-distro",
    require => [ Wget::Fetch['download-malawi-modules'], Package['unzip']]
  }

  exec { 'move-malawi-modules':
    command => "mv /tmp/malawi-distro/* /tmp/malawi-distribution && rm -rf ${tomcat_home_dir}/.OpenMRS/modules/* && cp -r /tmp/malawi-distribution/openmrs_modules/* ${tomcat_home_dir}/.OpenMRS/modules/ && chown -R ${tomcat}:${tomcat} ${tomcat_home_dir}/.OpenMRS/modules",
    require => [ Wget::Fetch['download-malawi-modules'], Exec['extract-malawi-modules'], File["${tomcat_home_dir}/.OpenMRS/modules"]],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'move-malawi-war-file':
    command => "rm -rf /var/lib/${tomcat}/webapps/* && cp -r /tmp/malawi-distribution/openmrs_webapps/openmrs.war /var/lib/${tomcat}/webapps && chown -R ${tomcat}:${tomcat} /var/lib/${tomcat}/webapps",
    require => [ Wget::Fetch['download-malawi-modules'], Exec['extract-malawi-modules'] ],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

}