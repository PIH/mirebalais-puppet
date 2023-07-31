class openmrs::install_frontend(

  $frontend_name    = hiera('frontend_name'),
  $frontend_version = hiera('frontend_version'),

  $maven_frontend_group_id = hiera('maven_frontend_group_id'),

  $tomcat           = hiera('tomcat'),
  $tomcat_home_dir  = hiera('tomcat_home_dir'),
  $webapp_name      = hiera('webapp_name')

) {

  if ($frontend_name != "") {

    exec { 'delete-old-openmrs-frontend-contents':
      command => "rm -rf ${tomcat_home_dir}/.OpenMRS/frontend/*"
    }

    maven { "${tomcat_home_dir}/.OpenMRS/staging/${frontend_name}.zip":
      groupid => "${maven_frontend_group_id}",
      artifactid => "${frontend_name}",
      version => "${frontend_version}",
      ensure => latest,
      packaging => zip,
      repos => "${maven_download_repo}",
      require     => [ Exec['delete-old-frontend-contents'], File[ "${tomcat_home_dir}/.OpenMRS/staging"] ]
    }

    exec { 'extract-openmrs-frontend':
      command => "unzip -o ${tomcat_home_dir}/.OpenMRS/staging/${frontend_name}.zip -d /tmp/frontend",
      require => [ Maven["${tomcat_home_dir}/.OpenMRS/staging/${frontend_name}.zip"], Package['unzip']]
    }

    exec { 'move-openmrs-frontend-contents-to-config-dir':
      command => "mv /tmp/frontend/*/* ${tomcat_home_dir}/.OpenMRS/frontend",
      require => [Exec['extract-openmrs-frontend'], Exec['delete-old-openmrs-frontend-contents']]
    }

    exec { 'change-openmrs-frontend-owner-to-tomcat':
      command => "chown -R ${tomcat}:${tomcat} ${tomcat_home_dir}/.OpenMRS/frontend",
      require => Exec['move-openmrs-frontend-contents-to-config-dir']
    }

    ### I'm not sure if the below blocks are needed, but we should have them for now
    exec { 'link-configuration-into-frontend':
      command => "ln -s ${tomcat_home_dir}}/.OpenMRS/configuration/frontend ${tomcat_home_dir}/.OpenMRS/frontend/site",
      onlyif  => "test -f ${tomcat_home_dir}/.OpenMRS/configuration/frontend",
      # this folder doesn't exist for malawi so first test if the dir exist, if it does then do the ln
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
}
