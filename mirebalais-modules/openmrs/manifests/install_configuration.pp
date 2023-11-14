class openmrs::install_configuration (

  $openmrs_modules_temp_location = hiera('openmrs_modules_temp_location'),
  $openmrs_warfile_temp_location = hiera('openmrs_warfile_temp_location'),
  $tomcat_home_dir               = hiera('tomcat_home_dir'),
  $tomcat_webapp_dir             = hiera('tomcat_webapp_dir'),
  $webapp_name                   = hiera('webapp_name')

) {

  ## we need this to ensure that the openmrs directories exist
  require openmrs::config_files

  #Ensure that old modules and war files are deleted
  exec { 'delete-old-openmrs-modules':
    command => "rm -rf ${tomcat_home_dir}/.OpenMRS/modules/*",
    path    => ['/bin', '/usr/bin'],
  }

  exec { "delete-old-$webapp_name-war-file":
    command => "rm -rf $tomcat_webapp_dir/$webapp_name.war",
    path    => ['/bin', '/usr/bin'],
  }

  # move modules and war file to their respective directories
  # and ensure tomcat is the owner
  exec { 'move-modules-to-openmrs-modules-dir':
    command  => "mv $openmrs_modules_temp_location/* ${tomcat_home_dir}/.OpenMRS/modules",
    path    => ['/bin', '/usr/bin'],
    require =>  [Exec['delete-old-openmrs-modules'], File["${tomcat_home_dir}/.OpenMRS/modules"]]
  }

  exec { 'ensure-modules-dir-have-tomcat-user-as-owner':
    command  => "chown -R tomcat:tomcat ${tomcat_home_dir}/.OpenMRS/modules",
    path    => ['/bin', '/usr/bin'],
    require => Exec['move-modules-to-openmrs-modules-dir'],
    notify => [ Exec['tomcat-restart'] ]
  }

  exec { 'move-war-file-to-tomcat-webapp-dir':
    command  => "mv $openmrs_warfile_temp_location/$webapp_name.war $tomcat_webapp_dir",
    path    => ['/bin', '/usr/bin'],
    require => [Exec["delete-old-$webapp_name-war-file"], File["${tomcat_home_dir}/.OpenMRS/modules"]]
  }

  exec { 'ensure-war-file-has-tomcat-user-as-owner':
    command  => "chown -R tomcat:tomcat $tomcat_webapp_dir",
    path    => ['/bin', '/usr/bin'],
    require => Exec['move-war-file-to-tomcat-webapp-dir'],
    notify => [ Exec['tomcat-restart'] ]

  }

}
