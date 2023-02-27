class openmrs::openmrs_config_files (

  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir'),
  $webapp_name     = hiera('webapp_name')
)
{


  file { "${tomcat_home_dir}/.OpenMRS":
    ensure => directory,
    owner  => $tomcat,
    group  => $tomcat,
    }

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
}