class openmrs::config_files (

  # needed for log4j2
  $config_name     = hiera('config_name'),
  $config_version  = hiera('config_version'),

  #
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

      # I think currently ocl is required for the pihemr only
      file { "${tomcat_home_dir}/.OpenMRS/configuration/ocl/":
        ensure  => directory,
        owner   => $tomcat,
        group   => $tomcat,
        mode    => '0644',
        require => File["${tomcat_home_dir}/.OpenMRS/configuration"]
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