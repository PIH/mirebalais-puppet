class openmrs (

  $openmrs_db                   = hiera('openmrs_db'),
  $openmrs_db_user              = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password          = decrypt(hiera('openmrs_db_password')),
  $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
  $package_release    = hiera('package_release'),
  $petl_mysql_user              = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password          = decrypt(hiera("petl_mysql_password")),
  $petl_warehouse_db            = hiera("petl_warehouse_db"),
  $petl_openmrs_connection_url  = hiera("petl_openmrs_connection_url"),
  $pih_malawi_distribution_version      = hiera('pih_malawi_distribution_version'),
  $pwa_enabled        = hiera('pwa_enabled'),
  $pwa_filename       = hiera('pwa_filename'),
  $pwa_webapp_name    = hiera('pwa_webapp_name'),
  $repo_url                     = decrypt(hiera('repo_url')),
  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir'),
  $webapp_name     = hiera('webapp_name'),

){

  file { '/etc/apt/apt.conf.d/99auth':
    ensure  => present,
    owner   => root,
    group   => root,
    content => 'APT::Get::AllowUnauthenticated yes;',
    mode    => '0644'
  }

  package { 'p7zip-full' :
    ensure => 'installed'
  }

  file { "${tomcat_home_dir}/.OpenMRS":
    ensure => directory,
    owner  => $tomcat,
    group  => $tomcat,
    require => File["${tomcat_home_dir}"]
  }

}
