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
  $petl_mysql_user              = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password          = decrypt(hiera("petl_mysql_password")),
  $petl_warehouse_db            = hiera("petl_warehouse_db"),
  $petl_openmrs_connection_url  = hiera("petl_openmrs_connection_url"),

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

  file { "${tomcat_home_dir}/.OpenMRS/warehouse-connection.properties":
    ensure  => present,
    content => template('openmrs/warehouse-connection.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0600',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  file { "${tomcat_home_dir}/.OpenMRS/modules":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  file { "/usr/local/malawi" :
    ensure => present
    owner   => root,
    group   => root,
  }

  file { "/usr/local/malawi/scripts" :
    ensure => present
    owner   => root,
    group   => root,
    require     => File['/usr/local/malawi']
  }

  file { '/usr/local/malawi/scripts/maven-setting.xml':
        content => template('openmrs/maven-setting.xml.erb'),
        require => [ File['/usr/local/malawi'], File['/usr/local/malawi/scripts'] ]
  }

  exec { 'cleanup-malawi-openmrs-distribution-dir':
    command => "rm -rf /tmp/malawi-openmrs-distribution && rm -rf /tmp/malawi-distro && rm -rf /tmp/malawi-distribution"
  }

  wget::fetch { 'build-malawi-openmrs-distribution':
    command    => "mvn dependency:get -U -Dartifact=$pih_malawi_distribution_version -s /usr/local/malawi/scripts/maven-settings.xml",
    require    => File['/usr/local/malawi/scripts']
  }

  wget::fetch { 'download-malawi-openmrs-distribution':
    command    => "mvn dependency:copy -Dartifact=$pih_malawi_distribution_version -DoutputDirectory=/tmp/distro -Dmdep.useBaseVersion=true -s /usr/local/malawi/scripts/maven-settings.xml",
    require    => [File['/usr/local/malawi/scripts'], Wget::Fetch['build-malawi-openmrs-distribution']]
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