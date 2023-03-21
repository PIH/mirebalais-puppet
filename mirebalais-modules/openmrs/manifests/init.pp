class openmrs (

  $package_name     = hiera('package_name')

) {

  if ($package_name == 'pihemr') {

    require openmrs::pihemr

  }

  if ($package_name == 'pihmalawi') {

    require openmrs::install_distribution_from_maven
    require openmrs::install_config_from_maven
    require openmrs::config_files
    #require openmrs::install_frontend
    require openmrs::install_configuration
    require openmrs::install_pwa

  }

}