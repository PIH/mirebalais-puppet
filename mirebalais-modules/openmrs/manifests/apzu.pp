class openmrs::apzu (
  $tomcat_home_dir      = hiera('tomcat_home_dir'),
  $tomcat               = hiera('tomcat'),
  $webapp_name          = hiera('webapp_name'),
  $openmrs_db           = hiera('openmrs_db'),
  $openmrs_db_user      = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password  = decrypt(hiera('openmrs_db_password')),
  $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),

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
    command => "rm -rf /tmp/malawi-modules && rm -rf /tmp/malawi-omods"
  }

  wget::fetch { 'download-malawi-modules':
    source      => "https://bamboo.pih-emr.org:81/malawi-repo/modules.zip",
    destination => "/tmp/malawi-modules",
    timeout     => 0,
    verbose     => false,
    redownload  => true,
    require     => Exec['cleanup-malawi-modules-dir']
  }

  exec { 'extract-malawi-modules':
    command => "unzip -o /tmp/malawi-modules -d /tmp/malawi-omods && mv /tmp/malawi-omods/* /tmp/malawi-omods/modules",
    require => [ Wget::Fetch['download-malawi-modules'], Package['unzip']]
  }

  exec { 'move-malawi-modules':
    command => "rm -rf ${tomcat_home_dir}/.OpenMRS/modules/* && cp -r /tmp/malawi-omods/modules/* ${tomcat_home_dir}/.OpenMRS/modules/ && chown -R ${tomcat}:${tomcat} ${tomcat_home_dir}/.OpenMRS/modules",
    require => [ Wget::Fetch['download-malawi-modules'], Exec['extract-malawi-modules'], File["${tomcat_home_dir}/.OpenMRS/modules"]],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

}