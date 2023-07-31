class openmrs::config_files (

  # needed for log4j2
  $config_name     = hiera('config_name'),
  $config_version  = hiera('config_version'),

  # runtime property values
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),

  # used for warehouse-connection.properties
  $petl_mysql_user              = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password          = decrypt(hiera("petl_mysql_password")),
  $petl_warehouse_db            = hiera("petl_warehouse_db"),
  $petl_openmrs_connection_url  = hiera("petl_openmrs_connection_url"),

  $package_name     = hiera('package_name'),
  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir'),
  $webapp_name     = hiera('webapp_name'),

  #Feature_toggles
  $reportingui_ad_hoc_analysis            = hiera('reportingui_ad_hoc_analysis'),
  $radiology_contrast_studies             = hiera('radiology_contrast_studies'),
  $appointmentscheduling_confidential     = hiera('appointmentscheduling_confidential'),
  $insurance_collection                   = hiera('insurance_collection'),
  $htmlformentryui_simpleform_navbuttons  = hiera('htmlformentryui_simpleform_navbuttons'),

)
  {

    file { "${tomcat_home_dir}/.OpenMRS":
      ensure => directory,
      owner  => $tomcat,
      group  => $tomcat,
    }

    # where we stage the frontend and config files
    file { "${tomcat_home_dir}/.OpenMRS/staging":
      ensure  => directory,
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

    file { "${tomcat_home_dir}/.OpenMRS/configuration":
      ensure  => directory,
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["${tomcat_home_dir}/.OpenMRS"]
    }

    file { "/home/${tomcat}/.OpenMRS/frontend":
      ensure => directory,
      require => [  File["/home/${tomcat}/.OpenMRS"] ]
    }

    # needed for malawi
    file { "${tomcat_home_dir}/.OpenMRS/images":
      ensure  => directory,
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["${tomcat_home_dir}/.OpenMRS"]
    }

    # I think currently ocl is required for the pihemr only
    file { "${tomcat_home_dir}/.OpenMRS/configuration/ocl":
      ensure  => directory,
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["${tomcat_home_dir}/.OpenMRS/configuration"]
    }

    file { "${tomcat_home_dir}/.OpenMRS/${webapp_name}-runtime.properties":
      ensure  => present,
      content => template('openmrs/openmrs-malawi-runtime.properties.erb'),
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["${tomcat_home_dir}/.OpenMRS"]
    }

    # feature_toggles.properties is currenly only used for pihemr distro
    if ($package_name == 'pihemr') {
      file { "${tomcat_home_dir}/.OpenMRS/feature_toggles.properties":
        ensure  => present,
        content => template('openmrs/feature_toggles.properties.erb'),
        owner   => $tomcat,
        group   => $tomcat,
        mode    => '0644',
        require => File["${tomcat_home_dir}/.OpenMRS"]
      }

    }

    # warehouse-connection.properties toggles is currently only used for pihmalawi distro
    if ($package_name == 'pihmalawi') {
      file { "${tomcat_home_dir}/.OpenMRS/warehouse-connection.properties":
        ensure  => present,
        content => template('openmrs/warehouse-connection.properties.erb'),
        owner   => $tomcat,
        group   => $tomcat,
        mode    => '0600',
        require => File["${tomcat_home_dir}/.OpenMRS"]
      }

      # log4j2.xml for pihmalawi
      file { "${tomcat_home_dir}/.OpenMRS/configuration/log4j2.xml":
        ensure  => present,
        source  => "/tmp/${config_name}-${config_version}/log4j2.xml",
        owner   => $tomcat,
        group   => $tomcat,
        mode    => '0644',
        require => [File["${tomcat_home_dir}/.OpenMRS"], File["${tomcat_home_dir}/.OpenMRS/configuration"]]
      }
    }
  }
