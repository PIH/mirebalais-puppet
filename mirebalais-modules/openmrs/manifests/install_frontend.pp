class openmrs::install_frontend(

  $frontend_name    = hiera('frontend_name'),
  $frontend_repo    = hiera('frontend_repo'),
  $frontend_url     = hiera('frontend_url'),
  $frontend_version = hiera('frontend_version'),

  $tomcat           = hiera('tomcat'),
  $tomcat_home_dir  = hiera('tomcat_home_dir'),
  $webapp_name      = hiera('webapp_name')

) {

    exec { 'delete-old-frontend-packages':
      command => "rm -rf /tmp/frontend*"
    }

    exec { 'delete-old-openmrs-frontend-contents':
      command => "rm -rf ${tomcat_home_dir}/.OpenMRS/frontend/*"
    }

    wget::fetch { 'download-openmrs-frontend':
      source      => $frontend_url,
      destination => "/tmp/${frontend_name}.zip",
      timeout     => 0,
      verbose     => false,
      redownload  => true,
      require => Exec['delete-old-frontend-packages']
    }

    exec { 'extract-openmrs-frontend':
      command => "unzip -o /tmp/${frontend_name}.zip -d /tmp/frontend",
      require => [ Wget::Fetch['download-openmrs-frontend'], Package['unzip']]
    }

    exec { 'move-openmrs-frontend-contents-to-config-dir':
      command => "mv /tmp/frontend/*/* ${tomcat_home_dir}/.OpenMRS/frontend",
      require => [Wget::Fetch['download-openmrs-frontend'], Exec['delete-old-openmrs-frontend-contents']]
    }

    exec { 'change-openmrs-frontend-owner-to-tomcat':
      command => "chown -R ${tomcat}:${tomcat} ${tomcat_home_dir}/.OpenMRS/frontend",
      require => Exec['move-openmrs-frontend-contents-to-config-dir']
    }

    ### I'm not sure if the below blocks are needed, but we should have them for now
    exec { 'link-configuration-into-frontend':
      command => "ln -s ${tomcat_home_dir}}/.OpenMRS/configuration/frontend ${tomcat_home_dir}/.OpenMRS/frontend/site",
      onlyif => "test -f ${tomcat_home_dir}/.OpenMRS/configuration/frontend", # this folder doesn't exist for malawi so first test if the dir exist, if it does then do the ln
      require => Exec['move-openmrs-frontend-contents-to-config-dir']
    }

    # hack to change webapp name in the frontend application after it has already been built into the deb
    exec { 'fix spa application webapp name':
      unless  => "test ${webapp_name} = openmrs",
      command => "sed -i 's/\/openmrs\([\/\"]\)/\/${webapp_name}\1/g' ${tomcat_home_dir}/.OpenMRS/frontend/index.html",
      require => Exec['move-openmrs-frontend-contents-to-config-dir']
    }

    # this is legacy, this is now handled by our custom app loader factor
    file { "${tomcat_home_dir}/.OpenMRS/appframework-config.json":
      ensure => absent
    }

  }